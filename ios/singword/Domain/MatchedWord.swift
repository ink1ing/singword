import Foundation

struct MatchedWord: Identifiable, Hashable {
    var id: String { word }

    let word: String
    let pos: String
    let definition: String
    let source: String
}
