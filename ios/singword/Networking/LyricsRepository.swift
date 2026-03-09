import Foundation

final class LyricsRepository {
    private let primary: LyricsDataSource
    private let secondary: LyricsDataSource?

    init(primary: LyricsDataSource, secondary: LyricsDataSource? = nil) {
        self.primary = primary
        self.secondary = secondary
    }

    func searchLyrics(_ query: String) async -> LyricsResult {
        switch await primary.search(query: query) {
        case .success(let trackName, let artistName, let lyrics, let provider):
            return .success(trackName: trackName, artistName: artistName, lyrics: lyrics, provider: provider)
        case .notFound:
            guard let secondary else { return .notFound }
            return await secondary.search(query: query)
        case .networkError(let message):
            return .networkError(message)
        case .providerError(let provider, let message):
            return .providerError(provider: provider, message: message)
        }
    }

    func searchCandidates(_ query: String, limit: Int = 5) async -> LyricsCandidateResult {
        switch await searchCandidates(using: primary, query: query, limit: limit) {
        case .success(let candidates, let provider):
            return .success(candidates: candidates, provider: provider)
        case .notFound:
            guard let secondary else { return .notFound }
            return await searchCandidates(using: secondary, query: query, limit: limit)
        case .networkError(let message):
            return .networkError(message)
        case .providerError(let provider, let message):
            return .providerError(provider: provider, message: message)
        }
    }

    private func searchCandidates(
        using dataSource: LyricsDataSource,
        query: String,
        limit: Int
    ) async -> LyricsCandidateResult {
        if let candidateSource = dataSource as? LyricsCandidateDataSource {
            return await candidateSource.searchCandidates(query: query, limit: limit)
        }

        switch await dataSource.search(query: query) {
        case .success(let trackName, let artistName, let lyrics, let provider):
            return .success(
                candidates: [
                    LyricsCandidate(
                        trackName: trackName,
                        artistName: artistName,
                        lyrics: lyrics,
                        provider: provider,
                        duration: nil
                    )
                ],
                provider: provider
            )
        case .notFound:
            return .notFound
        case .networkError(let message):
            return .networkError(message)
        case .providerError(let provider, let message):
            return .providerError(provider: provider, message: message)
        }
    }
}
