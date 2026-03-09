import Foundation

enum SingWordShared {
    nonisolated static let appGroupIdentifier = "group.ink.singword.shared"
    nonisolated static let widgetKind = "SingWordWidget"
    nonisolated static let favoritesFileName = "favorites.json"
    nonisolated static let widgetSnapshotFileName = "widget_snapshot.json"
    nonisolated static let recentSearchesFileName = "recent_searches.json"
    nonisolated static let downloadedSongsFileName = "downloaded_songs.json"
    nonisolated static let importedTracksFileName = "imported_tracks.json"
    nonisolated static let importedTrackMatchesFileName = "imported_track_matches.json"
    nonisolated static let libraryImportStateFileName = "library_import_state.json"

    nonisolated static func sharedDefaults() -> UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    nonisolated static func sharedContainerDirectory(fileManager: FileManager = .default) -> URL? {
        fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)?
            .appendingPathComponent("SingWord", isDirectory: true)
    }

    nonisolated static func ensureSharedDirectory(fileManager: FileManager = .default) -> URL? {
        guard let directory = sharedContainerDirectory(fileManager: fileManager) else {
            return nil
        }
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
