import Foundation
import Combine

@MainActor
final class AppModel: ObservableObject {
    let settingsRepository: SettingsRepository
    let wordbookRepository: WordbookRepository
    let favoriteRepository: FavoriteRepository
    let lyricsRepository: LyricsRepository
    let favoritesStore: FavoritesStore

    @Published private(set) var themeMode: AppThemeMode

    init() {
        let settingsRepository = SettingsRepository()
        let favoriteRepository = FavoriteRepository()
        let wordbookRepository = WordbookRepository()
        let primarySource = LrclibLyricsDataSource()
        let geniusSource = GeniusLyricsDataSource(enabled: false, accessToken: "")

        self.settingsRepository = settingsRepository
        self.favoriteRepository = favoriteRepository
        self.wordbookRepository = wordbookRepository
        self.lyricsRepository = LyricsRepository(
            primary: primarySource,
            secondary: geniusSource.isEnabled() ? geniusSource : nil
        )
        self.favoritesStore = FavoritesStore(repository: favoriteRepository)
        self.themeMode = settingsRepository.getThemeMode()
    }

    func setThemeMode(_ mode: AppThemeMode) {
        settingsRepository.setThemeMode(mode)
        themeMode = mode
    }
}
