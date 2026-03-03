package com.singword.app.data.remote

import java.io.IOException
import java.util.concurrent.TimeUnit
import okhttp3.OkHttpClient
import retrofit2.HttpException
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

class LrclibLyricsDataSource : LyricsDataSource, LyricsCandidateDataSource {
    override val providerName: String = "lrclib"

    private val api: LrclibApi by lazy {
        val client = OkHttpClient.Builder()
            .connectTimeout(10, TimeUnit.SECONDS)
            .readTimeout(10, TimeUnit.SECONDS)
            .addInterceptor { chain ->
                val request = chain.request().newBuilder()
                    .header("User-Agent", "SingWord/1.0.0")
                    .build()
                chain.proceed(request)
            }
            .build()

        Retrofit.Builder()
            .baseUrl("https://lrclib.net/")
            .client(client)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(LrclibApi::class.java)
    }

    override suspend fun search(query: String): LyricsResult {
        return when (val candidateResult = searchCandidates(query, limit = 1)) {
            is LyricsCandidateResult.Success -> {
                val selected = candidateResult.candidates.firstOrNull()
                if (selected == null) {
                    LyricsResult.NotFound
                } else {
                    LyricsResult.Success(
                        trackName = selected.trackName,
                        artistName = selected.artistName,
                        lyrics = selected.lyrics,
                        provider = selected.provider
                    )
                }
            }
            is LyricsCandidateResult.NotFound -> LyricsResult.NotFound
            is LyricsCandidateResult.NetworkError -> LyricsResult.NetworkError(candidateResult.message)
            is LyricsCandidateResult.ProviderError -> LyricsResult.ProviderError(
                provider = candidateResult.provider,
                message = candidateResult.message
            )
        }
    }

    override suspend fun searchCandidates(query: String, limit: Int): LyricsCandidateResult {
        return try {
            val tracks = api.search(query)
                .filter { !it.plainLyrics.isNullOrBlank() }
                .take(limit.coerceAtLeast(1))

            if (tracks.isEmpty()) {
                LyricsCandidateResult.NotFound
            } else {
                LyricsCandidateResult.Success(
                    candidates = tracks.map { track ->
                        LyricsCandidate(
                            trackName = track.trackName ?: query,
                            artistName = track.artistName.orEmpty(),
                            lyrics = track.plainLyrics.orEmpty(),
                            provider = providerName
                        )
                    },
                    provider = providerName
                )
            }
        } catch (e: IOException) {
            LyricsCandidateResult.NetworkError("网络异常，请检查连接后重试")
        } catch (e: HttpException) {
            LyricsCandidateResult.ProviderError(providerName, "歌词服务异常（HTTP ${e.code()}）")
        } catch (e: Exception) {
            LyricsCandidateResult.ProviderError(providerName, e.message ?: "歌词服务异常")
        }
    }
}
