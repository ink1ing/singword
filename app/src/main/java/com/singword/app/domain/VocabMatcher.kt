package com.singword.app.domain

import com.singword.app.data.local.wordbook.WordEntry

object VocabMatcher {

    /**
     * Match tokenized words against loaded wordbooks.
     * @param tokens  Set of lowercase words from lyrics
     * @param wordbooks  Map<lowercase_word, Pair<WordEntry, source_label>>
     * @return List of matched words, sorted alphabetically
     */
    fun match(
        tokens: Set<String>,
        wordbooks: Map<String, Pair<WordEntry, String>>
    ): List<MatchedWord> {
        return tokens
            .mapNotNull { token ->
                wordbooks[token]?.let { (entry, source) ->
                    MatchedWord(
                        word = entry.word,
                        pos = entry.pos,
                        def = entry.def,
                        source = source
                    )
                }
            }
            .sortedBy { it.word }
    }
}
