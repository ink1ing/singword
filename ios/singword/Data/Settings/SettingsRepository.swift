import Foundation

enum ToggleResult {
    case accepted
    case rejected(reason: String)
}

final class SettingsRepository {
    private let defaults: UserDefaults
    private let themeModeKey = "theme_mode"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func getSelectionMap() -> [WordbookId: Bool] {
        Dictionary(uniqueKeysWithValues: WordbookId.allCases.map { ($0, isEnabled($0)) })
    }

    func getEnabledWordbooks() -> [WordbookId] {
        WordbookId.allCases.filter { isEnabled($0) }
    }

    func getThemeMode() -> AppThemeMode {
        let raw = defaults.string(forKey: themeModeKey) ?? AppThemeMode.system.rawValue
        return AppThemeMode(rawValue: raw) ?? .system
    }

    func setThemeMode(_ mode: AppThemeMode) {
        defaults.set(mode.rawValue, forKey: themeModeKey)
    }

    func toggleWordbook(_ id: WordbookId) -> ToggleResult {
        let current = isEnabled(id)
        if current && getEnabledWordbooks().count == 1 {
            return .rejected(reason: "至少保留一个词表开启")
        }
        setEnabled(id, enabled: !current)
        return .accepted
    }

    func isEnabled(_ id: WordbookId) -> Bool {
        let key = key(for: id)
        if defaults.object(forKey: key) == nil {
            return id == .cet4
        }
        return defaults.bool(forKey: key)
    }

    private func setEnabled(_ id: WordbookId, enabled: Bool) {
        defaults.set(enabled, forKey: key(for: id))
    }

    private func key(for id: WordbookId) -> String {
        id.rawValue
    }
}
