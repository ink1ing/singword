package com.singword.app.data.local.wordbook

data class WordbookMeta(
    val id: WordbookId,
    val assetName: String,
    val label: String
)

object WordbookCatalog {
    val all = listOf(
        WordbookMeta(WordbookId.CET4, "cet4", "CET-4"),
        WordbookMeta(WordbookId.CET6, "cet6", "CET-6"),
        WordbookMeta(WordbookId.IELTS, "ielts", "IELTS"),
        WordbookMeta(WordbookId.TOEFL, "toefl", "TOEFL")
    )

    fun metaFor(id: WordbookId): WordbookMeta = all.first { it.id == id }
}
