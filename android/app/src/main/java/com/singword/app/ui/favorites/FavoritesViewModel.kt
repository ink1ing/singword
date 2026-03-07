package com.singword.app.ui.favorites

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.singword.app.data.local.db.FavoriteRepository
import com.singword.app.data.local.db.FavoriteWord
import com.singword.app.data.local.song.DownloadedSongRepository
import com.singword.app.data.local.song.SongMatchSnapshot
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class FavoritesViewModel(
    private val favoriteRepository: FavoriteRepository,
    private val downloadedSongRepository: DownloadedSongRepository
) : ViewModel() {
    val favorites: StateFlow<List<FavoriteWord>> = favoriteRepository.getAllFavorites()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val downloadedSongs: StateFlow<List<SongMatchSnapshot>> = downloadedSongRepository.getAll()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    fun removeFavorite(word: FavoriteWord) {
        viewModelScope.launch(Dispatchers.IO) {
            favoriteRepository.delete(word)
        }
    }

    fun removeDownloadedSong(song: SongMatchSnapshot) {
        viewModelScope.launch(Dispatchers.IO) {
            downloadedSongRepository.delete(song)
        }
    }
}
