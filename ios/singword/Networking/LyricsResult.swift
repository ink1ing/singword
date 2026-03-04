import Foundation

enum LyricsResult {
    case success(trackName: String, artistName: String, lyrics: String, provider: String)
    case notFound
    case networkError(String)
    case providerError(provider: String, message: String)
}
