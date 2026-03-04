import Foundation

struct LyricsCandidate: Hashable, Codable {
    let trackName: String
    let artistName: String
    let lyrics: String
    let provider: String
}
