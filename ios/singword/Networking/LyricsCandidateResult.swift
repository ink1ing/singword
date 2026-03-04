import Foundation

enum LyricsCandidateResult {
    case success(candidates: [LyricsCandidate], provider: String)
    case notFound
    case networkError(String)
    case providerError(provider: String, message: String)
}
