import Foundation
import Combine

struct SettingsUiState {
    var selection: [WordbookId: Bool] = [:]
    var themeMode: AppThemeMode = .system
    var warning: String?
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var uiState: SettingsUiState

    private let settingsRepository: SettingsRepository
    private let onThemeModeChanged: (AppThemeMode) -> Void

    init(
        settingsRepository: SettingsRepository,
        onThemeModeChanged: @escaping (AppThemeMode) -> Void
    ) {
        self.settingsRepository = settingsRepository
        self.onThemeModeChanged = onThemeModeChanged
        self.uiState = SettingsUiState(
            selection: settingsRepository.getSelectionMap(),
            themeMode: settingsRepository.getThemeMode(),
            warning: nil
        )
    }

    func toggle(_ id: WordbookId) {
        switch settingsRepository.toggleWordbook(id) {
        case .accepted:
            uiState.selection = settingsRepository.getSelectionMap()
            uiState.warning = nil
        case .rejected(let reason):
            uiState.warning = reason
        }
    }

    func clearWarning() {
        uiState.warning = nil
    }

    func setThemeMode(_ mode: AppThemeMode) {
        settingsRepository.setThemeMode(mode)
        onThemeModeChanged(mode)
        uiState.themeMode = mode
        uiState.warning = nil
    }
}
