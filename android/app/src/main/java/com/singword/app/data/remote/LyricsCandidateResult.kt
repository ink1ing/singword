package com.singword.app.data.remote

sealed interface LyricsCandidateResult {
    data class Success(
        val candidates: List<LyricsCandidate>,
        val provider: String
    ) : LyricsCandidateResult

    data object NotFound : LyricsCandidateResult

    data class NetworkError(val message: String) : LyricsCandidateResult

    data class ProviderError(
        val provider: String,
        val message: String
    ) : LyricsCandidateResult
}
