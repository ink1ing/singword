package com.singword.app.data.local.prefs

import com.singword.app.data.local.wordbook.WordbookId
import com.singword.app.ui.theme.AppThemeMode

class SettingsRepository(
    private val prefsManager: PrefsManager
) {
    fun getSelectionMap(): Map<WordbookId, Boolean> = prefsManager.getSelectionMap()

    fun getEnabledWordbooks(): List<WordbookId> = prefsManager.getEnabledWordbooks()

    fun getThemeMode(): AppThemeMode = prefsManager.getThemeMode()

    fun setThemeMode(mode: AppThemeMode) {
        prefsManager.setThemeMode(mode)
    }

    fun toggleWordbook(id: WordbookId): ToggleResult {
        val current = prefsManager.isEnabled(id)
        if (current && prefsManager.getEnabledWordbooks().size == 1) {
            return ToggleResult.Rejected("至少保留一个词表开启")
        }
        prefsManager.setEnabled(id, !current)
        return ToggleResult.Accepted
    }
}

sealed interface ToggleResult {
    data object Accepted : ToggleResult
    data class Rejected(val reason: String) : ToggleResult
}
