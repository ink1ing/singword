import Foundation

actor AppleMusicImportRepository {
    private let tracksURL: URL
    private let matchesURL: URL
    private var trackCache: [ImportedTrack]?
    private var matchCache: [ImportedTrackMatch]?

    init(fileManager: FileManager = .default) {
        let fallbackRoot = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let fallbackDirectory = fallbackRoot.appendingPathComponent("SingWord", isDirectory: true)

        let directory = SingWordShared.ensureSharedDirectory(fileManager: fileManager) ?? fallbackDirectory
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        self.tracksURL = directory.appendingPathComponent(SingWordShared.importedTracksFileName)
        self.matchesURL = directory.appendingPathComponent(SingWordShared.importedTrackMatchesFileName)
    }

    func getAllTracks() -> [ImportedTrack] {
        loadTracksIfNeeded()
            .sorted { lhs, rhs in
                if lhs.status == rhs.status {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
                return lhs.importedAt > rhs.importedAt
            }
    }

    func getAllMatches() -> [ImportedTrackMatch] {
        loadMatchesIfNeeded()
    }

    func replaceTracks(_ tracks: [ImportedTrack]) {
        trackCache = tracks
        persistTracks(tracks)
    }

    func upsertTrack(_ track: ImportedTrack) {
        var tracks = loadTracksIfNeeded()
        tracks.removeAll { $0.id == track.id }
        tracks.append(track)
        trackCache = tracks
        persistTracks(tracks)
    }

    func upsertMatch(_ match: ImportedTrackMatch) {
        var matches = loadMatchesIfNeeded()
        matches.removeAll { $0.trackID == match.trackID }
        matches.append(match)
        matchCache = matches
        persistMatches(matches)
    }

    func removeMatch(trackID: String) {
        var matches = loadMatchesIfNeeded()
        matches.removeAll { $0.trackID == trackID }
        matchCache = matches
        persistMatches(matches)
    }

    func prune(toTrackIDs trackIDs: Set<String>) {
        let tracks = loadTracksIfNeeded().filter { trackIDs.contains($0.id) }
        let matches = loadMatchesIfNeeded().filter { trackIDs.contains($0.trackID) }
        trackCache = tracks
        matchCache = matches
        persistTracks(tracks)
        persistMatches(matches)
    }

    private func loadTracksIfNeeded() -> [ImportedTrack] {
        if let trackCache {
            return trackCache
        }

        guard let data = try? Data(contentsOf: tracksURL) else {
            trackCache = []
            return []
        }

        let decoded = (try? JSONDecoder().decode([ImportedTrack].self, from: data)) ?? []
        trackCache = decoded
        return decoded
    }

    private func loadMatchesIfNeeded() -> [ImportedTrackMatch] {
        if let matchCache {
            return matchCache
        }

        guard let data = try? Data(contentsOf: matchesURL) else {
            matchCache = []
            return []
        }

        let decoded = (try? JSONDecoder().decode([ImportedTrackMatch].self, from: data)) ?? []
        matchCache = decoded
        return decoded
    }

    private func persistTracks(_ tracks: [ImportedTrack]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(tracks) {
            try? data.write(to: tracksURL, options: .atomic)
        }
    }

    private func persistMatches(_ matches: [ImportedTrackMatch]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(matches) {
            try? data.write(to: matchesURL, options: .atomic)
        }
    }
}
