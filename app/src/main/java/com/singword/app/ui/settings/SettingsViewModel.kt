package com.singword.app.ui.settings

import androidx.lifecycle.ViewModel
import com.singword.app.data.local.prefs.SettingsRepository
import com.singword.app.data.local.prefs.ToggleResult
import com.singword.app.data.local.wordbook.WordbookId
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

data class SettingsUiState(
    val selection: Map<WordbookId, Boolean> = emptyMap(),
    val warning: String? = null
)

class SettingsViewModel(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(
        SettingsUiState(selection = settingsRepository.getSelectionMap())
    )
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    fun toggle(id: WordbookId) {
        when (val result = settingsRepository.toggleWordbook(id)) {
            ToggleResult.Accepted -> {
                _uiState.update {
                    it.copy(
                        selection = settingsRepository.getSelectionMap(),
                        warning = null
                    )
                }
            }
            is ToggleResult.Rejected -> {
                _uiState.update {
                    it.copy(warning = result.reason)
                }
            }
        }
    }

    fun clearWarning() {
        _uiState.update { it.copy(warning = null) }
    }
}
