package com.singword.app.domain

import com.singword.app.data.local.wordbook.WordEntry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class VocabMatcherTest {

    @Test
    fun match_returnsSortedMatchedWords() {
        val tokens = setOf("banana", "apple", "none")
        val wordbooks = mapOf(
            "apple" to (WordEntry("apple", "n.", "苹果") to "CET-4"),
            "banana" to (WordEntry("banana", "n.", "香蕉") to "IELTS")
        )

        val matched = VocabMatcher.match(tokens, wordbooks)
        assertEquals(2, matched.size)
        assertEquals("apple", matched[0].word)
        assertEquals("banana", matched[1].word)
        assertEquals("CET-4", matched[0].source)
    }

    @Test
    fun match_returnsEmptyWhenNoHits() {
        val matched = VocabMatcher.match(
            tokens = setOf("x", "y"),
            wordbooks = emptyMap()
        )
        assertTrue(matched.isEmpty())
    }

    @Test
    fun match_usesSingleEntryPerToken() {
        val matched = VocabMatcher.match(
            tokens = setOf("apple"),
            wordbooks = mapOf("apple" to (WordEntry("apple", "n.", "苹果") to "CET-4"))
        )
        assertEquals(1, matched.size)
        assertEquals("apple", matched.first().word)
        assertEquals("CET-4", matched.first().source)
    }
}
