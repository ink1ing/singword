import SwiftUI

struct RootTabView: View {
    @ObservedObject var appModel: AppModel

    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var libraryImportStore: LibraryImportStore
    @StateObject private var favoritesViewModel: FavoritesViewModel
    @StateObject private var settingsViewModel: SettingsViewModel

    init(appModel: AppModel) {
        self.appModel = appModel

        _searchViewModel = StateObject(
            wrappedValue: SearchViewModel(
                lyricsRepository: appModel.lyricsRepository,
                wordbookRepository: appModel.wordbookRepository,
                settingsRepository: appModel.settingsRepository,
                favoritesStore: appModel.favoritesStore,
                recentSearchStore: appModel.recentSearchStore,
                downloadedSongsStore: appModel.downloadedSongsStore,
                widgetSnapshotStore: appModel.widgetSnapshotStore
            )
        )

        _libraryImportStore = StateObject(
            wrappedValue: appModel.libraryImportStore
        )

        _favoritesViewModel = StateObject(
            wrappedValue: FavoritesViewModel(
                favoritesStore: appModel.favoritesStore,
                downloadedSongsStore: appModel.downloadedSongsStore
            )
        )

        _settingsViewModel = StateObject(
            wrappedValue: SettingsViewModel(
                settingsRepository: appModel.settingsRepository,
                onThemeModeChanged: { mode in
                    appModel.setThemeMode(mode)
                }
            )
        )
    }

    var body: some View {
        TabView {
            SearchFlowView(viewModel: searchViewModel)
                .tabItem {
                    Label("搜索", systemImage: "magnifyingglass")
                }

            LibraryFlowView(
                viewModel: libraryImportStore,
                favoriteWords: searchViewModel.favoriteWords,
                onToggleFavorite: { word in
                    searchViewModel.toggleFavorite(word)
                }
            )
                .tabItem {
                    Label("Library", systemImage: "music.note.list")
                }

            FavoritesFlowView(
                viewModel: favoritesViewModel,
                favoriteWords: searchViewModel.favoriteWords,
                onToggleFavorite: { word in
                    searchViewModel.toggleFavorite(word)
                }
            )
                .tabItem {
                    Label("收藏", systemImage: "heart")
                }

            SettingsFlowView(viewModel: settingsViewModel)
                .tabItem {
                    Label("设置", systemImage: "gear")
                }
        }
    }
}
