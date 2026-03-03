package com.singword.app.acceptance

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import com.singword.app.data.local.db.AppDatabase
import com.singword.app.data.local.db.FavoriteRepository
import com.singword.app.data.local.prefs.PrefsManager
import com.singword.app.data.local.prefs.SettingsRepository
import com.singword.app.data.local.wordbook.WordbookId
import com.singword.app.data.local.wordbook.WordbookLoadResult
import com.singword.app.data.local.wordbook.WordbookRepository
import com.singword.app.data.remote.LyricsDataSource
import com.singword.app.data.remote.LyricsRepository
import com.singword.app.data.remote.LyricsResult
import com.singword.app.domain.LyricsProcessor
import com.singword.app.domain.VocabMatcher
import com.singword.app.ui.search.SearchErrorCode
import com.singword.app.ui.search.SearchViewModel
import com.singword.app.ui.search.shouldShowRetry
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class AcceptanceFlowTest {
    private lateinit var context: Context
    private lateinit var prefsManager: PrefsManager
    private lateinit var settingsRepository: SettingsRepository
    private lateinit var wordbookRepository: WordbookRepository
    private lateinit var db: AppDatabase
    private lateinit var favoriteRepository: FavoriteRepository

    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
        clearPrefs()

        prefsManager = PrefsManager(context)
        settingsRepository = SettingsRepository(prefsManager)
        wordbookRepository = WordbookRepository(context)
        db = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        favoriteRepository = FavoriteRepository(db.favoriteDao())
    }

    @After
    fun teardown() {
        db.close()
        clearPrefs()
    }

    @Test
    fun scenario1_shapeOfYou_returnsLyricsAndHitsAtLeastFive() = runBlocking {
        setEnabledOnly(WordbookId.CET4)

        val loaded = wordbookRepository.loadEnabledWordbooks(settingsRepository.getEnabledWordbooks())
        assertTrue(loaded is WordbookLoadResult.Success)
        val words = (loaded as WordbookLoadResult.Success).words
        val lyrics = buildDeterministicLyrics(words.keys.toList(), minWords = 8)

        val lyricsResult = LyricsRepository(
            primary = FakeDataSource(
                LyricsResult.Success(
                    trackName = "Shape of You",
                    artistName = "Ed Sheeran",
                    lyrics = lyrics,
                    provider = "fake"
                )
            )
        ).searchLyrics("Shape of You")
        assertTrue("Expected LyricsResult.Success, got $lyricsResult", lyricsResult is LyricsResult.Success)
        val success = lyricsResult as LyricsResult.Success

        val tokens = LyricsProcessor.tokenize(success.lyrics)
        val matched = VocabMatcher.match(tokens, words)
        assertTrue("Expected >=5 matches, got ${matched.size}", matched.size >= 5)
    }

    @Test
    fun scenario2_nonexistentSong_showsNotFound() {
        setEnabledOnly(WordbookId.CET4)

        val viewModel = buildSearchViewModel(
            lyricsResult = LyricsResult.NotFound
        )
        viewModel.onQueryChanged("singword_nonexistent_song")
        viewModel.search()

        waitUntil { viewModel.uiState.value.errorCode == SearchErrorCode.LYRICS_NOT_FOUND }
        assertEquals(SearchErrorCode.LYRICS_NOT_FOUND, viewModel.uiState.value.errorCode)
    }

    @Test
    fun scenario3_allWordbooksDisabled_searchPromptsEnableAtLeastOne() {
        WordbookId.entries.forEach { prefsManager.setEnabled(it, false) }

        val viewModel = buildSearchViewModel(
            lyricsResult = LyricsResult.Success(
                trackName = "x",
                artistName = "y",
                lyrics = "abandon ability",
                provider = "fake"
            )
        )
        viewModel.onQueryChanged("any song")
        viewModel.search()

        waitUntil { viewModel.uiState.value.errorCode == SearchErrorCode.NO_WORDBOOK_SELECTED }
        assertEquals(SearchErrorCode.NO_WORDBOOK_SELECTED, viewModel.uiState.value.errorCode)
        assertTrue(viewModel.uiState.value.error.orEmpty().contains("至少一个词表"))
    }

    @Test
    fun scenario4_switchWordbook_changesHitCountAndSource() = runBlocking {
        val cet4Words = (wordbookRepository.loadEnabledWordbooks(listOf(WordbookId.CET4)) as WordbookLoadResult.Success).words
        val toeflWords = (wordbookRepository.loadEnabledWordbooks(listOf(WordbookId.TOEFL)) as WordbookLoadResult.Success).words

        val cet4Only = cet4Words.keys.filterNot { it in toeflWords }.take(2)
        val toeflOnly = toeflWords.keys.filterNot { it in cet4Words }.take(1)
        assertTrue("Expected CET-4 unique words for test setup", cet4Only.size == 2)
        assertTrue("Expected TOEFL unique words for test setup", toeflOnly.size == 1)

        val tokens = LyricsProcessor.tokenize((cet4Only + toeflOnly).joinToString(" "))
        val cet4Matched = VocabMatcher.match(tokens, cet4Words)
        val toeflMatched = VocabMatcher.match(tokens, toeflWords)

        assertTrue(cet4Matched.all { it.source == "CET-4" })
        assertTrue(toeflMatched.all { it.source == "TOEFL" })
        assertTrue(
            "Expected hit count to change after switching wordbook: CET4=${cet4Matched.size}, TOEFL=${toeflMatched.size}",
            cet4Matched.size != toeflMatched.size
        )
    }

    @Test
    fun scenario5_resultFavoriteImmediatelyVisibleInFavoritesState() {
        setEnabledOnly(WordbookId.CET4)
        val viewModel = buildSearchViewModel(
            lyricsResult = LyricsResult.Success(
                trackName = "demo",
                artistName = "demo",
                lyrics = "abandon ability",
                provider = "fake"
            )
        )

        viewModel.onQueryChanged("demo")
        viewModel.search()
        waitUntil { !viewModel.uiState.value.isLoading && viewModel.uiState.value.matchedWords.isNotEmpty() }

        val word = viewModel.uiState.value.matchedWords.first()
        viewModel.toggleFavorite(word)
        waitUntil { word.word in viewModel.favoriteWords.value }
        assertTrue(word.word in viewModel.favoriteWords.value)
    }

    @Test
    fun scenario6_deleteFavorite_syncsBackToResultState() {
        setEnabledOnly(WordbookId.CET4)
        val viewModel = buildSearchViewModel(
            lyricsResult = LyricsResult.Success(
                trackName = "demo",
                artistName = "demo",
                lyrics = "abandon ability",
                provider = "fake"
            )
        )

        viewModel.onQueryChanged("demo")
        viewModel.search()
        waitUntil { !viewModel.uiState.value.isLoading && viewModel.uiState.value.matchedWords.isNotEmpty() }

        val word = viewModel.uiState.value.matchedWords.first()
        viewModel.toggleFavorite(word)
        waitUntil { word.word in viewModel.favoriteWords.value }

        viewModel.toggleFavorite(word)
        waitUntil { word.word !in viewModel.favoriteWords.value }
        assertFalse(word.word in viewModel.favoriteWords.value)
    }

    @Test
    fun scenario7_networkError_showsRetryableErrorState() {
        setEnabledOnly(WordbookId.CET4)
        val viewModel = buildSearchViewModel(
            lyricsResult = LyricsResult.NetworkError("网络异常，请检查连接后重试")
        )
        viewModel.onQueryChanged("Shape of You")
        viewModel.search()

        waitUntil { viewModel.uiState.value.errorCode == SearchErrorCode.NETWORK_ERROR }
        assertEquals(SearchErrorCode.NETWORK_ERROR, viewModel.uiState.value.errorCode)
        assertTrue(shouldShowRetry(viewModel.uiState.value.errorCode))
    }

    private fun buildSearchViewModel(lyricsResult: LyricsResult): SearchViewModel {
        val lyricsRepository = LyricsRepository(primary = FakeDataSource(lyricsResult))
        return SearchViewModel(
            lyricsRepository = lyricsRepository,
            wordbookRepository = wordbookRepository,
            settingsRepository = settingsRepository,
            favoriteRepository = favoriteRepository
        )
    }

    private fun buildDeterministicLyrics(words: List<String>, minWords: Int): String {
        val selected = words.sorted().take(minWords)
        assertTrue("Expected at least $minWords words for deterministic lyrics", selected.size == minWords)
        return selected.joinToString(" ")
    }

    private fun setEnabledOnly(id: WordbookId) {
        WordbookId.entries.forEach { prefsManager.setEnabled(it, it == id) }
    }

    private fun clearPrefs() {
        context.getSharedPreferences("singword_prefs", Context.MODE_PRIVATE)
            .edit()
            .clear()
            .commit()
    }

    private fun waitUntil(
        timeoutMs: Long = 5_000,
        intervalMs: Long = 50,
        condition: () -> Boolean
    ) {
        val start = System.currentTimeMillis()
        while (System.currentTimeMillis() - start < timeoutMs) {
            if (condition()) return
            Thread.sleep(intervalMs)
        }
        throw AssertionError("Condition not met within ${timeoutMs}ms")
    }
}

private class FakeDataSource(
    private val response: LyricsResult
) : LyricsDataSource {
    override val providerName: String = "fake"
    override suspend fun search(query: String): LyricsResult = response
}
