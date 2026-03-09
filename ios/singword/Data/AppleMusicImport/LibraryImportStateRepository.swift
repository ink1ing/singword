import Foundation

actor LibraryImportStateRepository {
    private let fileURL: URL
    private var cache: LibraryImportProgress?

    init(fileManager: FileManager = .default) {
        let fallbackRoot = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let fallbackDirectory = fallbackRoot.appendingPathComponent("SingWord", isDirectory: true)

        let directory = SingWordShared.ensureSharedDirectory(fileManager: fileManager) ?? fallbackDirectory
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        self.fileURL = directory.appendingPathComponent(SingWordShared.libraryImportStateFileName)
    }

    func load() -> LibraryImportProgress {
        if let cache {
            return cache
        }

        guard let data = try? Data(contentsOf: fileURL) else {
            cache = .idle
            return .idle
        }

        let decoded = (try? JSONDecoder().decode(LibraryImportProgress.self, from: data)) ?? .idle
        cache = decoded
        return decoded
    }

    func save(_ progress: LibraryImportProgress) {
        cache = progress
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        if let data = try? encoder.encode(progress) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
