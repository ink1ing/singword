package com.singword.app.ui

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.singword.app.di.AppContainer
import com.singword.app.ui.favorites.FavoritesViewModel
import com.singword.app.ui.search.SearchViewModel
import com.singword.app.ui.settings.SettingsViewModel

class AppViewModelFactory(
    private val container: AppContainer
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return when {
            modelClass.isAssignableFrom(SearchViewModel::class.java) -> {
                SearchViewModel(
                    lyricsRepository = container.lyricsRepository,
                    wordbookRepository = container.wordbookRepository,
                    settingsRepository = container.settingsRepository,
                    favoriteRepository = container.favoriteRepository
                ) as T
            }
            modelClass.isAssignableFrom(FavoritesViewModel::class.java) -> {
                FavoritesViewModel(container.favoriteRepository) as T
            }
            modelClass.isAssignableFrom(SettingsViewModel::class.java) -> {
                SettingsViewModel(container.settingsRepository) as T
            }
            else -> throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}
