package com.singword.app.ui.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.singword.app.data.local.db.FavoriteRepository
import com.singword.app.data.local.db.FavoriteWord
import com.singword.app.data.local.prefs.SettingsRepository
import com.singword.app.data.local.song.DownloadedSongRepository
import com.singword.app.data.local.song.RecentSearchRepository
import com.singword.app.data.local.song.SongMatchSnapshot
import com.singword.app.data.local.widget.WidgetSnapshotStore
import com.singword.app.data.local.wordbook.WordEntry
import com.singword.app.data.local.wordbook.WordbookLoadResult
import com.singword.app.data.local.wordbook.WordbookRepository
import com.singword.app.data.remote.LyricsCandidate
import com.singword.app.data.remote.LyricsCandidateResult
import com.singword.app.data.remote.LyricsRepository
import com.singword.app.data.remote.LyricsResult
import com.singword.app.domain.LyricsProcessor
import com.singword.app.domain.MatchedWord
import com.singword.app.domain.VocabMatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class SearchErrorCode {
    NONE,
    EMPTY_QUERY,
    NO_WORDBOOK_SELECTED,
    WORDBOOK_MISSING_ASSET,
    WORDBOOK_PARSE_ERROR,
    LYRICS_NOT_FOUND,
    NETWORK_ERROR,
    PROVIDER_ERROR,
    UNKNOWN
}

data class SearchUiState(
    val query: String = "",
    val isLoading: Boolean = false,
    val trackName: String = "",
    val artistName: String = "",
    val provider: String = "",
    val candidates: List<LyricsCandidate> = emptyList(),
    val selectedCandidate: LyricsCandidate? = null,
    val matchedWords: List<MatchedWord> = emptyList(),
    val totalTokens: Int = 0,
    val isEmptyResult: Boolean = false,
    val error: String? = null,
    val errorCode: SearchErrorCode = SearchErrorCode.NONE
)

class SearchViewModel(
    private val lyricsRepository: LyricsRepository,
    private val wordbookRepository: WordbookRepository,
    private val settingsRepository: SettingsRepository,
    private val favoriteRepository: FavoriteRepository,
    private val recentSearchRepository: RecentSearchRepository,
    private val downloadedSongRepository: DownloadedSongRepository,
    private val widgetSnapshotStore: WidgetSnapshotStore
) : ViewModel() {

    private val _uiState = MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()

    val favoriteWords: StateFlow<Set<String>> = favoriteRepository.getAllFavoriteWords()
        .map { it.toSet() }
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptySet())

    val recentSearches: StateFlow<List<SongMatchSnapshot>> = recentSearchRepository.getAll()
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptyList())

    val downloadedSongIds: StateFlow<Set<String>> = downloadedSongRepository.getAllIds()
        .map { it.toSet() }
        .stateIn(viewModelScope, SharingStarted.Eagerly, emptySet())

    fun onQueryChanged(query: String) {
        _uiState.update { it.copy(query = query) }
    }

    fun searchCandidates(): Boolean {
        val query = _uiState.value.query.trim()
        if (query.isBlank()) {
            setError(
                message = "请输入歌名",
                code = SearchErrorCode.EMPTY_QUERY
            )
            return false
        }

        if (settingsRepository.getEnabledWordbooks().isEmpty()) {
            setError(
                message = "请先在设置中选择至少一个词表",
                code = SearchErrorCode.NO_WORDBOOK_SELECTED
            )
            return false
        }

        viewModelScope.launch(Dispatchers.IO) {
            _uiState.update {
                it.copy(
                    isLoading = true,
                    trackName = "",
                    artistName = "",
                    provider = "",
                    candidates = emptyList(),
                    selectedCandidate = null,
                    matchedWords = emptyList(),
                    totalTokens = 0,
                    isEmptyResult = false,
                    error = null,
                    errorCode = SearchErrorCode.NONE
                )
            }

            when (val candidateResult = lyricsRepository.searchCandidates(query, limit = 5)) {
                is LyricsCandidateResult.Success -> {
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            provider = candidateResult.provider,
                            candidates = candidateResult.candidates,
                            error = null,
                            errorCode = SearchErrorCode.NONE
                        )
                    }
                }
                is LyricsCandidateResult.NotFound -> {
                    setError(
                        message = "未找到歌词",
                        code = SearchErrorCode.LYRICS_NOT_FOUND
                    )
                }
                is LyricsCandidateResult.NetworkError -> {
                    setError(
                        message = candidateResult.message,
                        code = SearchErrorCode.NETWORK_ERROR
                    )
                }
                is LyricsCandidateResult.ProviderError -> {
                    setError(
                        message = candidateResult.message,
                        code = SearchErrorCode.PROVIDER_ERROR
                    )
                }
            }
        }

        return true
    }

    fun selectCandidate(candidate: LyricsCandidate) {
        viewModelScope.launch(Dispatchers.IO) {
            matchCandidate(candidate)
        }
    }

    fun search() {
        val query = _uiState.value.query.trim()
        if (query.isBlank()) {
            setError(
                message = "请输入歌名",
                code = SearchErrorCode.EMPTY_QUERY
            )
            return
        }

        viewModelScope.launch(Dispatchers.IO) {
            _uiState.update {
                it.copy(
                    isLoading = true,
                    trackName = "",
                    artistName = "",
                    provider = "",
                    candidates = emptyList(),
                    selectedCandidate = null,
                    matchedWords = emptyList(),
                    totalTokens = 0,
                    isEmptyResult = false,
                    error = null,
                    errorCode = SearchErrorCode.NONE
                )
            }

            when (val lyricsResult = lyricsRepository.searchLyrics(query)) {
                is LyricsResult.Success -> {
                    matchCandidate(
                        LyricsCandidate(
                            trackName = lyricsResult.trackName,
                            artistName = lyricsResult.artistName,
                            lyrics = lyricsResult.lyrics,
                            provider = lyricsResult.provider
                        )
                    )
                }
                is LyricsResult.NotFound -> {
                    setError(
                        message = "未找到歌词",
                        code = SearchErrorCode.LYRICS_NOT_FOUND
                    )
                }
                is LyricsResult.NetworkError -> {
                    setError(
                        message = lyricsResult.message,
                        code = SearchErrorCode.NETWORK_ERROR
                    )
                }
                is LyricsResult.ProviderError -> {
                    setError(
                        message = lyricsResult.message,
                        code = SearchErrorCode.PROVIDER_ERROR
                    )
                }
            }
        }
    }

    fun retryResult() {
        val candidate = _uiState.value.selectedCandidate
        if (candidate != null) {
            selectCandidate(candidate)
        } else {
            search()
        }
    }

    fun clearError() {
        _uiState.update {
            it.copy(error = null, errorCode = SearchErrorCode.NONE)
        }
    }

    fun toggleFavorite(word: MatchedWord) {
        viewModelScope.launch(Dispatchers.IO) {
            val current = favoriteWords.value
            if (word.word in current) {
                favoriteRepository.delete(
                    FavoriteWord(
                        word = word.word,
                        pos = word.pos,
                        def = word.def,
                        source = word.source
                    )
                )
            } else {
                favoriteRepository.upsert(
                    FavoriteWord(
                        word = word.word,
                        pos = word.pos,
                        def = word.def,
                        source = word.source
                    )
                )
            }
        }
    }

    fun loadSnapshot(snapshot: SongMatchSnapshot) {
        widgetSnapshotStore.save(snapshot)
        _uiState.update {
            it.copy(
                query = snapshot.trackName,
                isLoading = false,
                trackName = snapshot.trackName,
                artistName = snapshot.artistName,
                provider = snapshot.provider,
                candidates = emptyList(),
                selectedCandidate = null,
                matchedWords = snapshot.toMatchedWords(),
                totalTokens = snapshot.totalTokens,
                isEmptyResult = snapshot.matchedWords.isEmpty(),
                error = null,
                errorCode = SearchErrorCode.NONE
            )
        }
    }

    fun downloadCurrentSong() {
        val snapshot = currentSnapshot() ?: return
        viewModelScope.launch(Dispatchers.IO) {
            downloadedSongRepository.upsert(snapshot)
        }
    }

    fun isCurrentSongDownloaded(): Boolean {
        val snapshot = currentSnapshot() ?: return false
        return snapshot.id in downloadedSongIds.value
    }

    private fun loadEnabledWordbooksOrError(): Map<String, Pair<WordEntry, String>>? {
        val enabled = settingsRepository.getEnabledWordbooks()
        if (enabled.isEmpty()) {
            setError(
                message = "请先在设置中选择至少一个词表",
                code = SearchErrorCode.NO_WORDBOOK_SELECTED
            )
            return null
        }

        return when (val loadResult = wordbookRepository.loadEnabledWordbooks(enabled)) {
            is WordbookLoadResult.Success -> loadResult.words
            is WordbookLoadResult.MissingAsset -> {
                setError(
                    message = "词表文件缺失：${loadResult.assetPath}",
                    code = SearchErrorCode.WORDBOOK_MISSING_ASSET
                )
                null
            }
            is WordbookLoadResult.ParseError -> {
                setError(
                    message = "词表解析失败：${loadResult.assetPath}",
                    code = SearchErrorCode.WORDBOOK_PARSE_ERROR
                )
                null
            }
        }
    }

    private fun matchCandidate(candidate: LyricsCandidate) {
        _uiState.update {
            it.copy(
                isLoading = true,
                trackName = candidate.trackName,
                artistName = candidate.artistName,
                provider = candidate.provider,
                selectedCandidate = candidate,
                matchedWords = emptyList(),
                totalTokens = 0,
                isEmptyResult = false,
                error = null,
                errorCode = SearchErrorCode.NONE
            )
        }

        val wordbooks = loadEnabledWordbooksOrError() ?: return

        val tokens = LyricsProcessor.tokenize(candidate.lyrics)
        val matched = VocabMatcher.match(tokens, wordbooks)
        val snapshot = SongMatchSnapshot.fromMatchedWords(
            trackName = candidate.trackName,
            artistName = candidate.artistName,
            provider = candidate.provider,
            totalTokens = tokens.size,
            matchedWords = matched
        )
        widgetSnapshotStore.save(snapshot)
        viewModelScope.launch(Dispatchers.IO) {
            recentSearchRepository.upsert(snapshot)
        }
        _uiState.update {
            it.copy(
                isLoading = false,
                trackName = candidate.trackName,
                artistName = candidate.artistName,
                provider = candidate.provider,
                selectedCandidate = candidate,
                matchedWords = matched,
                totalTokens = tokens.size,
                isEmptyResult = matched.isEmpty(),
                error = null,
                errorCode = SearchErrorCode.NONE
            )
        }
    }

    private fun setError(message: String, code: SearchErrorCode) {
        _uiState.update {
            it.copy(
                isLoading = false,
                error = message,
                errorCode = code
            )
        }
    }

    private fun currentSnapshot(): SongMatchSnapshot? {
        val state = _uiState.value
        if (state.trackName.isBlank() || state.matchedWords.isEmpty()) return null
        return SongMatchSnapshot.fromMatchedWords(
            trackName = state.trackName,
            artistName = state.artistName,
            provider = state.provider,
            totalTokens = state.totalTokens,
            matchedWords = state.matchedWords
        )
    }
}
