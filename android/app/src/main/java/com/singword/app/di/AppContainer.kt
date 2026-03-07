package com.singword.app.di

import android.content.Context
import com.singword.app.BuildConfig
import com.singword.app.data.local.db.AppDatabase
import com.singword.app.data.local.db.FavoriteRepository
import com.singword.app.data.local.prefs.PrefsManager
import com.singword.app.data.local.prefs.SettingsRepository
import com.singword.app.data.local.song.DownloadedSongRepository
import com.singword.app.data.local.song.RecentSearchRepository
import com.singword.app.data.local.widget.WidgetSnapshotStore
import com.singword.app.data.local.wordbook.WordbookRepository
import com.singword.app.data.remote.GeniusLyricsDataSource
import com.singword.app.data.remote.LrclibLyricsDataSource
import com.singword.app.data.remote.LyricsDataSource
import com.singword.app.data.remote.LyricsRepository

class AppContainer(context: Context) {
    private val appContext = context.applicationContext

    private val prefsManager = PrefsManager(appContext)
    val settingsRepository = SettingsRepository(prefsManager)

    private val appDatabase = AppDatabase.getInstance(appContext)
    val favoriteRepository = FavoriteRepository(appDatabase.favoriteDao())
    val recentSearchRepository = RecentSearchRepository(appDatabase.recentSearchDao())
    val downloadedSongRepository = DownloadedSongRepository(appDatabase.downloadedSongDao())
    val widgetSnapshotStore = WidgetSnapshotStore(appContext)

    val wordbookRepository = WordbookRepository(appContext)

    private val primaryLyricsSource: LyricsDataSource = LrclibLyricsDataSource()
    private val geniusSource = GeniusLyricsDataSource(
        enabled = BuildConfig.GENIUS_ENABLED,
        accessToken = BuildConfig.GENIUS_TOKEN
    )

    val lyricsRepository = LyricsRepository(
        primary = primaryLyricsSource,
        secondary = if (geniusSource.isEnabled()) geniusSource else null
    )
}
