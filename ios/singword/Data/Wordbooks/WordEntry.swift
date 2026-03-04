import Foundation

struct WordEntry: Codable, Hashable {
    let word: String
    let pos: String
    let definition: String

    enum CodingKeys: String, CodingKey {
        case word
        case pos
        case definition = "def"
    }
}
