package com.singword.app.ui.favorites

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.singword.app.data.local.db.FavoriteRepository
import com.singword.app.data.local.db.FavoriteWord
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class FavoritesViewModel(
    private val favoriteRepository: FavoriteRepository
) : ViewModel() {
    val favorites: StateFlow<List<FavoriteWord>> = favoriteRepository.getAllFavorites()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    fun removeFavorite(word: FavoriteWord) {
        viewModelScope.launch(Dispatchers.IO) {
            favoriteRepository.delete(word)
        }
    }
}
