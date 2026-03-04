import Foundation

actor WordbookRepository {
    private var cache: [String: [String: WordEntry]] = [:]

    func loadWordbook(meta: WordbookMeta) -> WordbookLoadResult {
        if let cached = cache[meta.assetName] {
            return .success(words: cached.mapValues { entry in (entry, meta.label) })
        }

        let assetPath = "wordbooks/\(meta.assetName).json"
        guard let url = resolveWordbookURL(named: meta.assetName) else {
            return .missingAsset(assetPath: assetPath)
        }

        do {
            let data = try Data(contentsOf: url)
            let words = try JSONDecoder().decode([WordEntry].self, from: data)
            let mapped = words.reduce(into: [String: WordEntry]()) { result, entry in
                result[entry.word.lowercased()] = entry
            }
            cache[meta.assetName] = mapped
            return .success(words: mapped.mapValues { entry in (entry, meta.label) })
        } catch {
            return .parseError(assetPath: assetPath, reason: error.localizedDescription)
        }
    }

    func loadEnabledWordbooks(enabled: [WordbookId]) -> WordbookLoadResult {
        var result: [String: (WordEntry, String)] = [:]

        for id in enabled {
            let meta = WordbookCatalog.meta(for: id)
            switch loadWordbook(meta: meta) {
            case .success(let words):
                for (word, pair) in words where result[word] == nil {
                    result[word] = pair
                }
            case .missingAsset(let assetPath):
                return .missingAsset(assetPath: assetPath)
            case .parseError(let assetPath, let reason):
                return .parseError(assetPath: assetPath, reason: reason)
            }
        }

        return .success(words: result)
    }

    private func resolveWordbookURL(named assetName: String) -> URL? {
        if let url = Bundle.main.url(forResource: assetName, withExtension: "json", subdirectory: "wordbooks") {
            return url
        }
        if let url = Bundle.main.url(forResource: assetName, withExtension: "json", subdirectory: "Resources/wordbooks") {
            return url
        }
        return Bundle.main.url(forResource: assetName, withExtension: "json")
    }
}
