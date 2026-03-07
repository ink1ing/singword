package com.singword.app.data.local.widget

import android.content.Context
import com.singword.app.data.local.song.SongMatchSnapshot
import com.singword.app.data.local.song.SongSnapshotCodec
import com.singword.app.data.local.song.SongWordSnapshot
import org.json.JSONObject

class WidgetSnapshotStore(context: Context) {
    private val appContext = context.applicationContext
    private val prefs = appContext.getSharedPreferences("singword_widget_prefs", Context.MODE_PRIVATE)

    fun save(snapshot: SongMatchSnapshot) {
        val raw = JSONObject()
            .put("id", snapshot.id)
            .put("trackName", snapshot.trackName)
            .put("artistName", snapshot.artistName)
            .put("provider", snapshot.provider)
            .put("totalTokens", snapshot.totalTokens)
            .put("matchedWordsJson", SongSnapshotCodec.encode(snapshot.matchedWords))
            .put("timestamp", snapshot.timestamp)
            .toString()
        prefs.edit().putString(KEY_LAST_SNAPSHOT, raw).apply()
    }

    fun load(): SongMatchSnapshot? {
        val raw = prefs.getString(KEY_LAST_SNAPSHOT, null) ?: return null
        val json = runCatching { JSONObject(raw) }.getOrNull() ?: return null
        return SongMatchSnapshot(
            id = json.optString("id"),
            trackName = json.optString("trackName"),
            artistName = json.optString("artistName"),
            provider = json.optString("provider"),
            totalTokens = json.optInt("totalTokens"),
            matchedWords = SongSnapshotCodec.decode(json.optString("matchedWordsJson")),
            timestamp = json.optLong("timestamp")
        )
    }

    companion object {
        private const val KEY_LAST_SNAPSHOT = "last_snapshot"
    }
}
