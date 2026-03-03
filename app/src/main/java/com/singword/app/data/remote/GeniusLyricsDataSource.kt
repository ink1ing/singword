package com.singword.app.data.remote

class GeniusLyricsDataSource(
    private val enabled: Boolean,
    private val accessToken: String
) : LyricsDataSource {
    override val providerName: String = "genius"

    fun isEnabled(): Boolean = enabled && accessToken.isNotBlank()

    override suspend fun search(query: String): LyricsResult {
        if (!enabled) {
            return LyricsResult.ProviderError(providerName, "Genius fallback 已关闭")
        }
        if (accessToken.isBlank()) {
            return LyricsResult.ProviderError(providerName, "缺少 Genius Token")
        }
        return LyricsResult.ProviderError(providerName, "Genius fallback 预留中，暂未启用抓词逻辑")
    }
}
