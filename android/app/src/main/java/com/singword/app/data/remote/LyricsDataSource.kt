package com.singword.app.data.remote

interface LyricsDataSource {
    val providerName: String
    suspend fun search(query: String): LyricsResult
}
