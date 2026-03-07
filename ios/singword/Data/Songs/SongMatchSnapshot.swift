import Foundation

nonisolated struct SongWordSnapshot: Codable, Hashable, Identifiable, Sendable {
    var id: String { word }

    let word: String
    let pos: String
    let definition: String
    let source: String
}

nonisolated struct SongMatchSnapshot: Codable, Hashable, Identifiable, Sendable {
    let trackName: String
    let artistName: String
    let provider: String
    let totalTokens: Int
    let matchedWords: [SongWordSnapshot]
    let timestamp: TimeInterval

    var id: String {
        "\(trackName.lowercased())|\(artistName.lowercased())"
    }

    init(
        trackName: String,
        artistName: String,
        provider: String,
        totalTokens: Int,
        matchedWords: [SongWordSnapshot],
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.trackName = trackName
        self.artistName = artistName
        self.provider = provider
        self.totalTokens = totalTokens
        self.matchedWords = matchedWords
        self.timestamp = timestamp
    }

    init(
        trackName: String,
        artistName: String,
        provider: String,
        totalTokens: Int,
        matchedWords: [MatchedWord],
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.init(
            trackName: trackName,
            artistName: artistName,
            provider: provider,
            totalTokens: totalTokens,
            matchedWords: matchedWords.map {
                SongWordSnapshot(
                    word: $0.word,
                    pos: $0.pos,
                    definition: $0.definition,
                    source: $0.source
                )
            },
            timestamp: timestamp
        )
    }

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
