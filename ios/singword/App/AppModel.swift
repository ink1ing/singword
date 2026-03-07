import Foundation
import Combine

@MainActor
final class AppModel: ObservableObject {
    let settingsRepository: SettingsRepository
    let wordbookRepository: WordbookRepository
    let favoriteRepository: FavoriteRepository
    let recentSearchRepository: RecentSearchRepository
    let downloadedSongRepository: DownloadedSongRepository
    let lyricsRepository: LyricsRepository
    let favoritesStore: FavoritesStore
    let recentSearchStore: RecentSearchStore
    let downloadedSongsStore: DownloadedSongsStore
    let widgetSnapshotStore: WidgetSnapshotStore

    @Published private(set) var themeMode: AppThemeMode

    init() {
        let settingsRepository = SettingsRepository()
        let favoriteRepository = FavoriteRepository()
        let recentSearchRepository = RecentSearchRepository()
        let downloadedSongRepository = DownloadedSongRepository()
        let wordbookRepository = WordbookRepository()
        let widgetSnapshotStore = WidgetSnapshotStore()
        let primarySource = LrclibLyricsDataSource()
        let geniusSource = GeniusLyricsDataSource(enabled: false, accessToken: "")

        self.settingsRepository = settingsRepository
        self.favoriteRepository = favoriteRepository
        self.recentSearchRepository = recentSearchRepository
        self.downloadedSongRepository = downloadedSongRepository
        self.wordbookRepository = wordbookRepository
        self.lyricsRepository = LyricsRepository(
            primary: primarySource,
            secondary: geniusSource.isEnabled() ? geniusSource : nil
        )
        self.favoritesStore = FavoritesStore(repository: favoriteRepository)
        self.recentSearchStore = RecentSearchStore(repository: recentSearchRepository)
        self.downloadedSongsStore = DownloadedSongsStore(repository: downloadedSongRepository)
        self.widgetSnapshotStore = widgetSnapshotStore
        self.themeMode = settingsRepository.getThemeMode()
    }

    func setThemeMode(_ mode: AppThemeMode) {
        settingsRepository.setThemeMode(mode)
        themeMode = mode
    }
}
