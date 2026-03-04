package com.singword.app.data.local.wordbook

import androidx.test.core.app.ApplicationProvider
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertTrue
import org.junit.Test

class WordbookRepositoryTest {

    private val context = ApplicationProvider.getApplicationContext<android.content.Context>()
    private val repository = WordbookRepository(context)

    @Test
    fun loadEnabledWordbooks_success() {
        val result = repository.loadEnabledWordbooks(listOf(WordbookId.CET4))
        assertTrue(result is WordbookLoadResult.Success)
    }

    @Test
    fun loadWordbook_missingAsset() {
        val result = repository.loadWordbook(
            WordbookMeta(WordbookId.CET4, "missing_file", "MISSING")
        )
        assertTrue(result is WordbookLoadResult.MissingAsset)
    }

    @Test
    fun loadWordbook_parseError() {
        val testContext = InstrumentationRegistry.getInstrumentation().context
        val result = WordbookRepository(testContext).loadWordbook(
            WordbookMeta(WordbookId.CET4, "invalid", "INVALID")
        )
        assertTrue(result is WordbookLoadResult.ParseError)
    }
}
