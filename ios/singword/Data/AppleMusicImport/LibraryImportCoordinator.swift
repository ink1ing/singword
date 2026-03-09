import Foundation
import MusicKit

struct ImportedTrackProcessingResult: Sendable {
    let track: ImportedTrack
    let match: ImportedTrackMatch?
}

final class LibraryImportCoordinator: @unchecked Sendable {
    private let authorizationService: AppleMusicAuthorizationService
    private let lyricsRepository: LyricsRepository
    private let wordbookRepository: WordbookRepository
    private let settingsRepository: SettingsRepository

    init(
        authorizationService: AppleMusicAuthorizationService,
        lyricsRepository: LyricsRepository,
        wordbookRepository: WordbookRepository,
        settingsRepository: SettingsRepository
    ) {
        self.authorizationService = authorizationService
        self.lyricsRepository = lyricsRepository
        self.wordbookRepository = wordbookRepository
        self.settingsRepository = settingsRepository
    }

    func currentAccessStatus() async -> LibraryAccessStatus {
        await authorizationService.currentAccessStatus()
    }

    func requestAccessStatus() async -> LibraryAccessStatus {
        await authorizationService.requestAccessStatus()
    }

    func fetchAllLibrarySongs(
        batchSize: Int = 100,
        onBatch: @escaping @Sendable (_ fetchedCount: Int, _ latestBatchCount: Int) -> Void
    ) async throws -> [Song] {
        var request = MusicLibraryRequest<Song>()
        request.limit = batchSize
        request.offset = 0

        let response = try await request.response()
        var allSongs = Array(response.items)
        onBatch(allSongs.count, response.items.count)

        var currentBatch = response.items
        while let nextBatch = try await currentBatch.nextBatch(limit: batchSize) {
            allSongs.append(contentsOf: nextBatch)
            currentBatch = nextBatch
            onBatch(allSongs.count, nextBatch.count)
        }

        return allSongs
    }

    func mergeImportedTracks(
        songs: [Song],
        existingTracks: [ImportedTrack],
        existingMatches: [ImportedTrackMatch],
        storefront: String
    ) -> [ImportedTrack] {
        let existingByID = Dictionary(uniqueKeysWithValues: existingTracks.map { ($0.id, $0) })
        let matchedIDs = Set(existingMatches.map(\.trackID))

        return songs.map { song in
            let id = song.id.rawValue
            let artworkURL = song.artwork?.url(width: 512, height: 512)?.absoluteString ?? ""
            let importedAt = Date().timeIntervalSince1970

            if let existing = existingByID[id] {
                let preservedStatus: ImportedTrackStatus =
                    existing.status == .matched && matchedIDs.contains(id) ? .matched : .queued

                return ImportedTrack(
                    id: id,
                    title: song.title,
                    artistName: song.artistName,
                    albumTitle: song.albumTitle ?? "",
                    artworkURL: artworkURL,
                    duration: song.duration,
                    isrc: song.isrc ?? "",
                    storefront: storefront,
                    importedAt: importedAt,
                    status: preservedStatus,
                    failureReason: preservedStatus == .matched ? existing.failureReason : nil,
                    failureMessage: preservedStatus == .matched ? existing.failureMessage : ""
                )
            }

            return ImportedTrack(
                id: id,
                title: song.title,
                artistName: song.artistName,
                albumTitle: song.albumTitle ?? "",
                artworkURL: artworkURL,
                duration: song.duration,
                isrc: song.isrc ?? "",
                storefront: storefront,
                importedAt: importedAt,
                status: .queued,
                failureReason: nil,
                failureMessage: ""
            )
        }
    }

    func processTrack(_ track: ImportedTrack) async -> ImportedTrackProcessingResult {
        let enabledWordbooks = settingsRepository.getEnabledWordbooks()
        guard !enabledWordbooks.isEmpty else {
            return ImportedTrackProcessingResult(
                track: track.updating(
                    status: .failed,
                    failureReason: .providerFailed,
                    failureMessage: "请先启用至少一个词表"
                ),
                match: nil
            )
        }

        let wordbooks: [String: (WordEntry, String)]
        switch await wordbookRepository.loadEnabledWordbooks(enabled: enabledWordbooks) {
        case .success(let words):
            wordbooks = words
        case .missingAsset(let assetPath):
            return ImportedTrackProcessingResult(
                track: track.updating(
                    status: .failed,
                    failureReason: .providerFailed,
                    failureMessage: "词表缺失：\(assetPath)"
                ),
                match: nil
            )
        case .parseError(let assetPath, _):
            return ImportedTrackProcessingResult(
                track: track.updating(
                    status: .failed,
                    failureReason: .providerFailed,
                    failureMessage: "词表解析失败：\(assetPath)"
                ),
                match: nil
            )
        }

        var sawAmbiguous = false

        for query in strictQueries(for: track) {
            switch await lyricsRepository.searchCandidates(query, limit: 5) {
            case .success(let candidates, let provider):
                let exactMatches = candidates.filter { strictMatch(candidate: $0, track: track) }

                if exactMatches.count > 1 {
                    sawAmbiguous = true
                    continue
                }

                guard let matchedCandidate = exactMatches.first else {
                    continue
                }

                let tokens = LyricsProcessor.tokenize(matchedCandidate.lyrics)
                let matchedWords = VocabMatcher.match(tokens: tokens, wordbooks: wordbooks)
                let match = ImportedTrackMatch(
                    trackID: track.id,
                    lyricsProvider: provider,
                    resolvedTrackName: matchedCandidate.trackName,
                    resolvedArtistName: matchedCandidate.artistName,
                    totalTokens: tokens.count,
                    matchedWords: matchedWords.map {
                        SongWordSnapshot(
                            word: $0.word,
                            pos: $0.pos,
                            definition: $0.definition,
                            source: $0.source
                        )
                    },
                    matchedAt: Date().timeIntervalSince1970
                )
                return ImportedTrackProcessingResult(
                    track: track.updating(
                        status: .matched,
                        failureReason: nil,
                        failureMessage: ""
                    ),
                    match: match
                )

            case .notFound:
                continue
            case .networkError(let message):
                return ImportedTrackProcessingResult(
                    track: track.updating(
                        status: .failed,
                        failureReason: .networkFailed,
                        failureMessage: message
                    ),
                    match: nil
                )
            case .providerError(_, let message):
                return ImportedTrackProcessingResult(
                    track: track.updating(
                        status: .failed,
                        failureReason: .providerFailed,
                        failureMessage: message
                    ),
                    match: nil
                )
            }
        }

        if sawAmbiguous {
            return ImportedTrackProcessingResult(
                track: track.updating(
                    status: .failed,
                    failureReason: .ambiguousMatch,
                    failureMessage: "找到多条严格匹配结果，已跳过"
                ),
                match: nil
            )
        }

        return ImportedTrackProcessingResult(
            track: track.updating(
                status: .unmatched,
                failureReason: .lyricsNotFound,
                failureMessage: "未找到严格匹配的歌词结果"
            ),
            match: nil
        )
    }

    private func strictQueries(for track: ImportedTrack) -> [String] {
        titleVariants(for: track.title).map { title in
            "\(title) \(track.artistName)".trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func strictMatch(candidate: LyricsCandidate, track: ImportedTrack) -> Bool {
        let expectedArtist = canonicalArtist(track.artistName)
        guard !expectedArtist.isEmpty else { return false }

        let expectedTitles = Set(titleVariants(for: track.title).map(canonicalTitle))
        let candidateTitle = canonicalTitle(candidate.trackName)
        let candidateArtist = canonicalArtist(candidate.artistName)

        return expectedTitles.contains(candidateTitle) && candidateArtist == expectedArtist
    }

    private func titleVariants(for title: String) -> [String] {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        var variants = OrderedSet<String>()
        variants.append(trimmed)

        let withoutParentheses = trimmed.replacingOccurrences(
            of: #"\s*[\(\[].*?[\)\]]"#,
            with: "",
            options: .regularExpression
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        variants.append(withoutParentheses)

        let withoutFeaturing = withoutParentheses.replacingOccurrences(
            of: #"\s+(feat\.|ft\.|featuring)\s+.*$"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        variants.append(withoutFeaturing)

        let withoutVersionSuffix = withoutFeaturing.replacingOccurrences(
            of: #"\s+-\s+(live|acoustic|remaster(ed)?|version|mix|edit).*$"#,
            with: "",
            options: [.regularExpression, .caseInsensitive]
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        variants.append(withoutVersionSuffix)

        return variants.elements.filter { !$0.isEmpty }
    }

    private func canonicalTitle(_ value: String) -> String {
        canonical(value)
    }

    private func canonicalArtist(_ value: String) -> String {
        canonical(value)
    }

    private func canonical(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .replacingOccurrences(of: "&", with: " and ")
            .replacingOccurrences(of: #"[^\p{L}\p{N}]+"#, with: " ", options: .regularExpression)
            .replacingOccurrences(of: #"\s+"#, with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }
}

private struct OrderedSet<Element: Hashable> {
    private(set) var elements: [Element] = []
    private var storage: Set<Element> = []

    mutating func append(_ element: Element) {
        guard !storage.contains(element) else { return }
        storage.insert(element)
        elements.append(element)
    }
}
