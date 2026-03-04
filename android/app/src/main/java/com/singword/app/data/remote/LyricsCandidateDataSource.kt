package com.singword.app.data.remote

interface LyricsCandidateDataSource {
    suspend fun searchCandidates(query: String, limit: Int = 5): LyricsCandidateResult
}
