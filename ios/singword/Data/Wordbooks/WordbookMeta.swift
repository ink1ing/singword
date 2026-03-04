import Foundation

struct WordbookMeta: Hashable {
    let id: WordbookId
    let assetName: String
    let label: String
}

enum WordbookCatalog {
    nonisolated static let all: [WordbookMeta] = [
        WordbookMeta(id: .cet4, assetName: "cet4", label: "CET-4"),
        WordbookMeta(id: .cet6, assetName: "cet6", label: "CET-6"),
        WordbookMeta(id: .ielts, assetName: "ielts", label: "IELTS"),
        WordbookMeta(id: .toefl, assetName: "toefl", label: "TOEFL")
    ]

    nonisolated static func meta(for id: WordbookId) -> WordbookMeta {
        all.first { $0.id == id } ?? WordbookMeta(id: .cet4, assetName: "cet4", label: "CET-4")
    }
}
