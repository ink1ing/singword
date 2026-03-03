package com.singword.app.data.remote

import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class LyricsRepositoryTest {

    @Test
    fun returnsPrimarySuccess() = runTest {
        val repo = LyricsRepository(
            primary = FakeDataSource(LyricsResult.Success("a", "b", "lyrics", "lrclib")),
            secondary = FakeDataSource(LyricsResult.Success("x", "y", "lyrics", "genius"))
        )

        val result = repo.searchLyrics("shape of you")
        assertTrue(result is LyricsResult.Success && result.provider == "lrclib")
    }

    @Test
    fun fallsBackOnlyOnNotFound() = runTest {
        val repo = LyricsRepository(
            primary = FakeDataSource(LyricsResult.NotFound),
            secondary = FakeDataSource(LyricsResult.Success("x", "y", "lyrics", "genius"))
        )

        val result = repo.searchLyrics("unknown")
        assertTrue(result is LyricsResult.Success && result.provider == "genius")
    }

    @Test
    fun networkErrorDoesNotFallback() = runTest {
        val repo = LyricsRepository(
            primary = FakeDataSource(LyricsResult.NetworkError("timeout")),
            secondary = FakeDataSource(LyricsResult.Success("x", "y", "lyrics", "genius"))
        )

        val result = repo.searchLyrics("shape of you")
        assertTrue(result is LyricsResult.NetworkError)
    }

    @Test
    fun notFoundWithoutSecondaryStaysNotFound() = runTest {
        val repo = LyricsRepository(
            primary = FakeDataSource(LyricsResult.NotFound),
            secondary = null
        )

        val result = repo.searchLyrics("unknown")
        assertTrue(result is LyricsResult.NotFound)
    }

    @Test
    fun providerErrorDoesNotFallback() = runTest {
        val repo = LyricsRepository(
            primary = FakeDataSource(LyricsResult.ProviderError("lrclib", "500")),
            secondary = FakeDataSource(LyricsResult.Success("x", "y", "lyrics", "genius"))
        )

        val result = repo.searchLyrics("shape of you")
        assertTrue(result is LyricsResult.ProviderError)
    }

    @Test
    fun searchCandidatesReturnsPrimaryCandidates() = runTest {
        val repo = LyricsRepository(
            primary = FakeCandidateDataSource(
                LyricsCandidateResult.Success(
                    candidates = listOf(
                        LyricsCandidate("Shape of You", "Ed Sheeran", "lyrics", "lrclib")
                    ),
                    provider = "lrclib"
                )
            ),
            secondary = FakeDataSource(LyricsResult.Success("x", "y", "lyrics", "genius"))
        )

        val result = repo.searchCandidates("shape of you")
        assertTrue(result is LyricsCandidateResult.Success)
        val success = result as LyricsCandidateResult.Success
        assertEquals(1, success.candidates.size)
        assertEquals("lrclib", success.provider)
    }

    @Test
    fun searchCandidatesFallsBackOnlyOnNotFound() = runTest {
        val repo = LyricsRepository(
            primary = FakeCandidateDataSource(LyricsCandidateResult.NotFound),
            secondary = FakeCandidateDataSource(
                LyricsCandidateResult.Success(
                    candidates = listOf(
                        LyricsCandidate("Fallback Song", "Fallback Artist", "lyrics", "genius")
                    ),
                    provider = "genius"
                )
            )
        )

        val result = repo.searchCandidates("unknown")
        assertTrue(result is LyricsCandidateResult.Success)
        val success = result as LyricsCandidateResult.Success
        assertEquals("genius", success.provider)
        assertEquals("Fallback Song", success.candidates.first().trackName)
    }

    @Test
    fun searchCandidatesFallbackForLegacySource() = runTest {
        val repo = LyricsRepository(
            primary = FakeDataSource(
                LyricsResult.Success("legacy", "artist", "lyrics", "legacy-provider")
            ),
            secondary = null
        )

        val result = repo.searchCandidates("legacy")
        assertTrue(result is LyricsCandidateResult.Success)
        val success = result as LyricsCandidateResult.Success
        assertEquals(1, success.candidates.size)
        assertEquals("legacy-provider", success.provider)
        assertEquals("legacy", success.candidates.first().trackName)
    }
}

private class FakeDataSource(
    private val response: LyricsResult
) : LyricsDataSource {
    override val providerName: String = "fake"

    override suspend fun search(query: String): LyricsResult = response
}

private class FakeCandidateDataSource(
    private val response: LyricsCandidateResult
) : LyricsDataSource, LyricsCandidateDataSource {
    override val providerName: String = "fake-candidate"

    override suspend fun search(query: String): LyricsResult {
        return when (response) {
            is LyricsCandidateResult.Success -> {
                val candidate = response.candidates.firstOrNull()
                if (candidate == null) {
                    LyricsResult.NotFound
                } else {
                    LyricsResult.Success(
                        trackName = candidate.trackName,
                        artistName = candidate.artistName,
                        lyrics = candidate.lyrics,
                        provider = candidate.provider
                    )
                }
            }
            is LyricsCandidateResult.NotFound -> LyricsResult.NotFound
            is LyricsCandidateResult.NetworkError -> LyricsResult.NetworkError(response.message)
            is LyricsCandidateResult.ProviderError -> LyricsResult.ProviderError(
                provider = response.provider,
                message = response.message
            )
        }
    }

    override suspend fun searchCandidates(query: String, limit: Int): LyricsCandidateResult = response
}
