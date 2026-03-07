package com.singword.app.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import androidx.core.os.bundleOf
import com.singword.app.MainActivity
import com.singword.app.R
import com.singword.app.data.local.prefs.PrefsManager
import com.singword.app.data.local.widget.WidgetSnapshotStore
import com.singword.app.ui.theme.AppThemeMode

class SingWordWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle
    ) {
        updateAppWidget(context, appWidgetManager, appWidgetId)
    }

    companion object {
        private val wordViewIds = intArrayOf(
            R.id.widget_word_1,
            R.id.widget_word_2,
            R.id.widget_word_3,
            R.id.widget_word_4,
            R.id.widget_word_5,
            R.id.widget_word_6,
            R.id.widget_word_7,
            R.id.widget_word_8
        )

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val component = ComponentName(context, SingWordWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(component)
            ids.forEach { appWidgetId ->
                updateAppWidget(context, manager, appWidgetId)
            }
        }

        private fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val views = RemoteViews(context.packageName, R.layout.singword_widget)
            val snapshot = WidgetSnapshotStore(context).load()
            val isDark = resolveDarkMode(context)
            val options = appWidgetManager.getAppWidgetOptions(appWidgetId)
            val maxHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 0)
            val visibleWordCount = if (maxHeight >= 220) 8 else 4

            views.setInt(
                R.id.widget_root,
                "setBackgroundResource",
                if (isDark) R.drawable.widget_bg_dark else R.drawable.widget_bg_light
            )

            val titleColor = Color.parseColor(if (isDark) "#ECECEC" else "#1A1A18")
            val secondaryColor = Color.parseColor(if (isDark) "#9B9B9B" else "#6B6B6B")
            views.setTextColor(R.id.widget_title, titleColor)
            views.setTextColor(R.id.widget_empty, secondaryColor)

            if (snapshot == null) {
                views.setTextViewText(R.id.widget_title, "先搜索一首歌")
                views.setTextViewText(R.id.widget_empty, "输入歌名，提取高频词")
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                wordViewIds.forEach { id ->
                    views.setViewVisibility(id, View.GONE)
                }
            } else {
                views.setTextViewText(R.id.widget_title, "from「${snapshot.trackName}」")
                views.setViewVisibility(R.id.widget_empty, View.GONE)

                val lines = snapshot.matchedWords.take(visibleWordCount).map {
                    "${it.word} ${it.pos} ${it.def}"
                }

                wordViewIds.forEachIndexed { index, id ->
                    val text = lines.getOrNull(index)
                    if (text == null) {
                        views.setViewVisibility(id, View.GONE)
                    } else {
                        views.setViewVisibility(id, View.VISIBLE)
                        views.setTextViewText(id, text)
                        views.setTextColor(id, if (index == 0) titleColor else secondaryColor)
                    }
                }
            }

            val launchIntent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun resolveDarkMode(context: Context): Boolean {
            return when (PrefsManager(context).getThemeMode()) {
                AppThemeMode.DARK -> true
                AppThemeMode.LIGHT -> false
                AppThemeMode.SYSTEM -> {
                    val nightModeFlags = context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK
                    nightModeFlags == Configuration.UI_MODE_NIGHT_YES
                }
            }
        }
    }
}
