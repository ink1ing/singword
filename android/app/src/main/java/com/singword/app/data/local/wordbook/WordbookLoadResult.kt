package com.singword.app.data.local.wordbook

sealed interface WordbookLoadResult {
    data class Success(
        val words: Map<String, Pair<WordEntry, String>>
    ) : WordbookLoadResult

    data class MissingAsset(val assetPath: String) : WordbookLoadResult

    data class ParseError(
        val assetPath: String,
        val reason: String
    ) : WordbookLoadResult
}
