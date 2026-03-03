package com.singword.app.data.local.prefs

import androidx.test.core.app.ApplicationProvider
import com.singword.app.data.local.wordbook.WordbookId
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class SettingsRepositoryTest {
    private lateinit var context: android.content.Context
    private lateinit var repository: SettingsRepository

    @Before
    fun setup() {
        context = ApplicationProvider.getApplicationContext()
        clearPrefs()
        repository = SettingsRepository(PrefsManager(context))
    }

    @After
    fun teardown() {
        clearPrefs()
    }

    @Test
    fun rejectDisablingLastWordbook() {
        // Force deterministic state: CET4 on, others off.
        val prefs = PrefsManager(context)
        WordbookId.entries.forEach { prefs.setEnabled(it, false) }
        prefs.setEnabled(WordbookId.CET4, true)

        val result = repository.toggleWordbook(WordbookId.CET4)
        assertTrue(result is ToggleResult.Rejected)
        assertTrue(repository.getSelectionMap()[WordbookId.CET4] == true)
    }

    @Test
    fun toggleAcceptedWhenThereIsAnotherEnabled() {
        val prefs = PrefsManager(context)
        WordbookId.entries.forEach { prefs.setEnabled(it, false) }
        prefs.setEnabled(WordbookId.CET4, true)
        prefs.setEnabled(WordbookId.IELTS, true)

        val result = repository.toggleWordbook(WordbookId.IELTS)
        assertTrue(result is ToggleResult.Accepted)
        assertEquals(false, repository.getSelectionMap()[WordbookId.IELTS])
        assertEquals(true, repository.getSelectionMap()[WordbookId.CET4])
    }

    private fun clearPrefs() {
        context.getSharedPreferences("singword_prefs", android.content.Context.MODE_PRIVATE)
            .edit()
            .clear()
            .commit()
    }
}
