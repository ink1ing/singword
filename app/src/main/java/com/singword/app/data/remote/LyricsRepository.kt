package com.singword.app.data.remote

class LyricsRepository(
    private val primary: LyricsDataSource,
    private val secondary: LyricsDataSource? = null
) {
    suspend fun searchLyrics(query: String): LyricsResult {
        return when (val primaryResult = primary.search(query)) {
            is LyricsResult.Success -> primaryResult
            is LyricsResult.NotFound -> secondary?.search(query) ?: LyricsResult.NotFound
            is LyricsResult.NetworkError -> primaryResult
            is LyricsResult.ProviderError -> primaryResult
        }
    }

    suspend fun searchCandidates(query: String, limit: Int = 5): LyricsCandidateResult {
        return when (val primaryResult = searchCandidates(primary, query, limit)) {
            is LyricsCandidateResult.Success -> primaryResult
            is LyricsCandidateResult.NotFound -> {
                val backup = secondary ?: return LyricsCandidateResult.NotFound
                searchCandidates(backup, query, limit)
            }
            is LyricsCandidateResult.NetworkError -> primaryResult
            is LyricsCandidateResult.ProviderError -> primaryResult
        }
    }

    private suspend fun searchCandidates(
        dataSource: LyricsDataSource,
        query: String,
        limit: Int
    ): LyricsCandidateResult {
        val candidateSource = dataSource as? LyricsCandidateDataSource
        if (candidateSource != null) {
            return candidateSource.searchCandidates(query, limit)
        }

        return when (val result = dataSource.search(query)) {
            is LyricsResult.Success -> LyricsCandidateResult.Success(
                candidates = listOf(
                    LyricsCandidate(
                        trackName = result.trackName,
                        artistName = result.artistName,
                        lyrics = result.lyrics,
                        provider = result.provider
                    )
                ),
                provider = result.provider
            )
            is LyricsResult.NotFound -> LyricsCandidateResult.NotFound
            is LyricsResult.NetworkError -> LyricsCandidateResult.NetworkError(result.message)
            is LyricsResult.ProviderError -> LyricsCandidateResult.ProviderError(
                provider = result.provider,
                message = result.message
            )
        }
    }
}
