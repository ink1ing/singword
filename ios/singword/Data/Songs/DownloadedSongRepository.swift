import Foundation

actor DownloadedSongRepository {
    private let fileURL: URL
    private var cache: [SongMatchSnapshot]?

    init(fileManager: FileManager = .default) {
        let fallbackRoot = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let fallbackDirectory = fallbackRoot.appendingPathComponent("SingWord", isDirectory: true)

        let directory = SingWordShared.ensureSharedDirectory(fileManager: fileManager) ?? fallbackDirectory
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        self.fileURL = directory.appendingPathComponent(SingWordShared.downloadedSongsFileName)
    }

    func getAll() -> [SongMatchSnapshot] {
        loadIfNeeded()
            .sorted { $0.timestamp > $1.timestamp }
    }

    func upsert(_ snapshot: SongMatchSnapshot) {
        var items = loadIfNeeded()
        items.removeAll { $0.id == snapshot.id }
        items.append(snapshot)
        cache = items
        persist(items)
    }

    func delete(_ snapshot: SongMatchSnapshot) {
        var items = loadIfNeeded()
        items.removeAll { $0.id == snapshot.id }
        cache = items
        persist(items)
    }

    private func loadIfNeeded() -> [SongMatchSnapshot] {
        if let cache {
            return cache
        }

        guard let data = try? Data(contentsOf: fileURL) else {
            cache = []
            return []
        }

        let decoded = (try? JSONDecoder().decode([SongMatchSnapshot].self, from: data)) ?? []
        cache = decoded
        return decoded
    }

    private func persist(_ items: [SongMatchSnapshot]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
