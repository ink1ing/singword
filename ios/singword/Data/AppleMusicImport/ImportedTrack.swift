import Foundation

nonisolated enum ImportedTrackStatus: String, Codable, Hashable, Sendable {
    case queued
    case matchingLyrics
    case matched
    case unmatched
    case failed
    case cancelled
}

nonisolated enum ImportedTrackFailureReason: String, Codable, Hashable, Sendable {
    case authorizationDenied = "authorization_denied"
    case subscriptionUnavailable = "subscription_unavailable"
    case regionUnavailable = "region_unavailable"
    case lyricsNotFound = "lyrics_not_found"
    case ambiguousMatch = "ambiguous_match"
    case networkFailed = "network_failed"
    case providerFailed = "provider_failed"
    case cancelled = "cancelled"
}

nonisolated struct ImportedTrack: Codable, Hashable, Identifiable, Sendable {
    let id: String
    let title: String
    let artistName: String
    let albumTitle: String
    let artworkURL: String
    let duration: TimeInterval?
    let isrc: String
    let storefront: String
    let importedAt: TimeInterval
    let status: ImportedTrackStatus
    let failureReason: ImportedTrackFailureReason?
    let failureMessage: String
}

nonisolated struct ImportedTrackMatch: Codable, Hashable, Identifiable, Sendable {
    let trackID: String
    let lyricsProvider: String
    let resolvedTrackName: String
    let resolvedArtistName: String
    let totalTokens: Int
    let matchedWords: [SongWordSnapshot]
    let matchedAt: TimeInterval

    var id: String { trackID }

    var matchedWordItems: [MatchedWord] {
        matchedWords.map {
            MatchedWord(
                word: $0.word,
                pos: $0.pos,
                definition: $0.definition,
                source: $0.source
            )
        }
    }
}

nonisolated enum LibraryImportPhase: String, Codable, Hashable, Sendable {
    case idle
    case checkingAccess
    case scanningLibrary
    case matchingLyrics
    case paused
    case completed
    case cancelled
    case blocked
}

nonisolated struct LibraryImportProgress: Codable, Hashable, Sendable {
    let phase: LibraryImportPhase
    let totalCount: Int
    let queuedCount: Int
    let processedCount: Int
    let matchedCount: Int
    let unmatchedCount: Int
    let failedCount: Int
    let currentTrackTitle: String
    let isRunning: Bool

    static let idle = LibraryImportProgress(
        phase: .idle,
        totalCount: 0,
        queuedCount: 0,
        processedCount: 0,
        matchedCount: 0,
        unmatchedCount: 0,
        failedCount: 0,
        currentTrackTitle: "",
        isRunning: false
    )
}

nonisolated enum LibraryAccessStatus: Hashable, Sendable {
    case ready(storefront: String)
    case needsAuthorization
    case denied
    case restricted
    case subscriptionUnavailable
    case regionUnavailable
    case unavailable(message: String)
}

extension ImportedTrack {
    func updating(
        status: ImportedTrackStatus? = nil,
        failureReason: ImportedTrackFailureReason? = nil,
        failureMessage: String? = nil
    ) -> ImportedTrack {
        ImportedTrack(
            id: id,
            title: title,
            artistName: artistName,
            albumTitle: albumTitle,
            artworkURL: artworkURL,
            duration: duration,
            isrc: isrc,
            storefront: storefront,
            importedAt: importedAt,
            status: status ?? self.status,
            failureReason: failureReason,
            failureMessage: failureMessage ?? self.failureMessage
        )
    }

    func asFavoriteSnapshot(match: ImportedTrackMatch?) -> SongMatchSnapshot {
        SongMatchSnapshot(
            trackName: title,
            artistName: artistName,
            provider: match?.lyricsProvider ?? "library",
            totalTokens: match?.totalTokens ?? 0,
            matchedWords: match?.matchedWordItems ?? [],
            timestamp: Date().timeIntervalSince1970
        )
    }
}
