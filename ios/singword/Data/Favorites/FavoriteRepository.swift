import Foundation

actor FavoriteRepository {
    private let fileURL: URL
    private var cache: [FavoriteWord]?

    init(fileManager: FileManager = .default) {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())

        let folder = appSupport.appendingPathComponent("SingWord", isDirectory: true)
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        self.fileURL = folder.appendingPathComponent("favorites.json")
    }

    func getAllFavorites() -> [FavoriteWord] {
        let favorites = loadIfNeeded()
        return favorites.sorted { $0.timestamp > $1.timestamp }
    }

    func getAllFavoriteWords() -> Set<String> {
        Set(getAllFavorites().map { $0.word })
    }

    func upsert(_ word: FavoriteWord) {
        var favorites = loadIfNeeded()
        favorites.removeAll { $0.word == word.word }
        favorites.append(word)
        cache = favorites
        persist(favorites)
    }

    func delete(_ word: FavoriteWord) {
        var favorites = loadIfNeeded()
        favorites.removeAll { $0.word == word.word }
        cache = favorites
        persist(favorites)
    }

    private func loadIfNeeded() -> [FavoriteWord] {
        if let cache {
            return cache
        }

        guard let data = try? Data(contentsOf: fileURL) else {
            cache = []
            return []
        }

        let decoded = (try? JSONDecoder().decode([FavoriteWord].self, from: data)) ?? []
        cache = decoded
        return decoded
    }

    private func persist(_ favorites: [FavoriteWord]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(favorites) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
