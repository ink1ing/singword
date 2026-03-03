package com.singword.app.domain

import java.util.Locale

object LyricsProcessor {

    fun normalizeToken(raw: String): String {
        return raw
            .replace('’', '\'')
            .lowercase(Locale.US)
            .replace("'", "")
            .replace(Regex("[^a-z]"), "")
            .trim()
    }

    fun tokenize(lyrics: String): Set<String> {
        return lyrics
            .split(Regex("\\s+"))
            .map(::normalizeToken)
            .filter { it.length > 1 }
            .toSet()
    }
}
