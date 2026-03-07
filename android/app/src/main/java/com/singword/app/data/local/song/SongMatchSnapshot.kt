package com.singword.app.data.local.song

import com.singword.app.domain.MatchedWord

data class SongWordSnapshot(
    val word: String,
    val pos: String,
    val def: String,
    val source: String
)

data class SongMatchSnapshot(
    val id: String,
    val trackName: String,
    val artistName: String,
    val provider: String,
    val totalTokens: Int,
    val matchedWords: List<SongWordSnapshot>,
    val timestamp: Long = System.currentTimeMillis()
) {
    companion object {
        fun createId(trackName: String, artistName: String): String {
            return "${trackName.trim().lowercase()}|${artistName.trim().lowercase()}"
        }

        fun fromMatchedWords(
            trackName: String,
            artistName: String,
            provider: String,
            totalTokens: Int,
            matchedWords: List<MatchedWord>,
            timestamp: Long = System.currentTimeMillis()
        ): SongMatchSnapshot {
            return SongMatchSnapshot(
                id = createId(trackName, artistName),
                trackName = trackName,
                artistName = artistName,
                provider = provider,
                totalTokens = totalTokens,
                matchedWords = matchedWords.map {
                    SongWordSnapshot(
                        word = it.word,
                        pos = it.pos,
                        def = it.def,
                        source = it.source
                    )
                },
                timestamp = timestamp
            )
        }
    }

    fun toMatchedWords(): List<MatchedWord> = matchedWords.map {
        MatchedWord(
            word = it.word,
            pos = it.pos,
            def = it.def,
            source = it.source
        )
    }
}
