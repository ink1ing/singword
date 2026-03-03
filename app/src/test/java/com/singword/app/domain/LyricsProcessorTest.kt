package com.singword.app.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class LyricsProcessorTest {

    @Test
    fun normalizeToken_stripsPunctuationAndApostrophe() {
        assertEquals("dont", LyricsProcessor.normalizeToken("Don't!"))
        assertEquals("cant", LyricsProcessor.normalizeToken("Can’t"))
        assertEquals("shape", LyricsProcessor.normalizeToken("shape,"))
    }

    @Test
    fun tokenize_deduplicatesAndFiltersShortTokens() {
        val tokens = LyricsProcessor.tokenize("You you, me! a i don't Don't")
        assertTrue("you" in tokens)
        assertTrue("dont" in tokens)
        assertTrue("me" in tokens)
        assertEquals(3, tokens.size)
    }

    @Test
    fun tokenize_handlesBlankLyrics() {
        assertTrue(LyricsProcessor.tokenize("   \n\t ").isEmpty())
    }
}
