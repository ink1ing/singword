package com.singword.app.data.remote

sealed interface LyricsResult {
    data class Success(
        val trackName: String,
        val artistName: String,
        val lyrics: String,
        val provider: String
    ) : LyricsResult

    data object NotFound : LyricsResult

    data class NetworkError(val message: String) : LyricsResult

    data class ProviderError(
        val provider: String,
        val message: String
    ) : LyricsResult
}
