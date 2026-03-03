package com.singword.app.data.local.prefs

import android.content.Context
import com.singword.app.data.local.wordbook.WordbookId

class PrefsManager(context: Context) {

    private val prefs = context.getSharedPreferences("singword_prefs", Context.MODE_PRIVATE)

    private fun keyFor(id: WordbookId): String = when (id) {
        WordbookId.CET4 -> "cet4"
        WordbookId.CET6 -> "cet6"
        WordbookId.IELTS -> "ielts"
        WordbookId.TOEFL -> "toefl"
    }

    fun isEnabled(id: WordbookId): Boolean {
        val default = id == WordbookId.CET4
        return prefs.getBoolean(keyFor(id), default)
    }

    fun setEnabled(id: WordbookId, enabled: Boolean) {
        prefs.edit().putBoolean(keyFor(id), enabled).apply()
    }

    fun getEnabledWordbooks(): List<WordbookId> {
        return WordbookId.entries.filter { isEnabled(it) }
    }

    fun getSelectionMap(): Map<WordbookId, Boolean> {
        return WordbookId.entries.associateWith { isEnabled(it) }
    }
}
