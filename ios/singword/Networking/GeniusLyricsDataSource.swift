import Foundation

final class GeniusLyricsDataSource: LyricsDataSource {
    let providerName: String = "genius"

    private let enabled: Bool
    private let accessToken: String

    init(enabled: Bool, accessToken: String) {
        self.enabled = enabled
        self.accessToken = accessToken
    }

    func isEnabled() -> Bool {
        enabled && !accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func search(query: String) async -> LyricsResult {
        if !enabled {
            return .providerError(provider: providerName, message: "Genius fallback 已关闭")
        }
        if accessToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .providerError(provider: providerName, message: "缺少 Genius Token")
        }
        return .providerError(provider: providerName, message: "Genius fallback 预留中，暂未启用抓词逻辑")
    }
}
