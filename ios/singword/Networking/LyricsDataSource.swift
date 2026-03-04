import Foundation

protocol LyricsDataSource {
    var providerName: String { get }
    func search(query: String) async -> LyricsResult
}

protocol LyricsCandidateDataSource {
    func searchCandidates(query: String, limit: Int) async -> LyricsCandidateResult
}
