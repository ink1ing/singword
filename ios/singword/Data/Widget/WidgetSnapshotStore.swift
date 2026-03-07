import Foundation
#if canImport(WidgetKit)
import WidgetKit
#endif

nonisolated struct WidgetWordSnapshot: Codable, Hashable, Identifiable, Sendable {
    var id: String { word }

    let word: String
    let pos: String
    let definition: String
}

nonisolated struct SearchWidgetSnapshot: Codable, Sendable {
    let trackName: String
    let artistName: String
    let words: [WidgetWordSnapshot]
    let updatedAt: TimeInterval
}

actor WidgetSnapshotStore {
    private let fileManager: FileManager
    private let fileURL: URL?

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.fileURL = SingWordShared.ensureSharedDirectory(fileManager: fileManager)?
            .appendingPathComponent(SingWordShared.widgetSnapshotFileName)
    }

    func save(trackName: String, artistName: String, matchedWords: [MatchedWord]) {
        guard !matchedWords.isEmpty, let fileURL else {
            return
        }

        let snapshot = SearchWidgetSnapshot(
            trackName: trackName,
            artistName: artistName,
            words: matchedWords.prefix(12).map {
                WidgetWordSnapshot(word: $0.word, pos: $0.pos, definition: $0.definition)
            },
            updatedAt: Date().timeIntervalSince1970
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        if let data = try? encoder.encode(snapshot) {
            try? data.write(to: fileURL, options: .atomic)
            #if canImport(WidgetKit)
            WidgetCenter.shared.reloadTimelines(ofKind: SingWordShared.widgetKind)
            #endif
        }
    }

    func load() -> SearchWidgetSnapshot? {
        guard let fileURL, fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return try? JSONDecoder().decode(SearchWidgetSnapshot.self, from: data)
    }
}
