import Foundation

struct FavoriteWord: Codable, Hashable, Identifiable {
    var id: String { word }

    let word: String
    let pos: String
    let definition: String
    let source: String
    let timestamp: TimeInterval

    init(
        word: String,
        pos: String,
        definition: String,
        source: String,
        timestamp: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.word = word
        self.pos = pos
        self.definition = definition
        self.source = source
        self.timestamp = timestamp
    }

    enum CodingKeys: String, CodingKey {
        case word
        case pos
        case definition = "def"
        case source
        case timestamp
    }
}
