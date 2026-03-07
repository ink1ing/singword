package com.singword.app.data.local.db

import android.content.Context
import androidx.room.AutoMigration
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import com.singword.app.data.local.song.DownloadedSongDao
import com.singword.app.data.local.song.DownloadedSongEntity
import com.singword.app.data.local.song.RecentSearchDao
import com.singword.app.data.local.song.RecentSearchEntity

@Database(
    entities = [FavoriteWord::class, RecentSearchEntity::class, DownloadedSongEntity::class],
    version = 2,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun favoriteDao(): FavoriteDao
    abstract fun recentSearchDao(): RecentSearchDao
    abstract fun downloadedSongDao(): DownloadedSongDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getInstance(context: Context): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "singword.db"
                )
                    .addMigrations(MIGRATION_1_2)
                    .build()
                    .also { INSTANCE = it }
            }
        }

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(db: SupportSQLiteDatabase) {
                db.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS recent_searches (
                        id TEXT NOT NULL PRIMARY KEY,
                        trackName TEXT NOT NULL,
                        artistName TEXT NOT NULL,
                        provider TEXT NOT NULL,
                        totalTokens INTEGER NOT NULL,
                        matchedWordsJson TEXT NOT NULL,
                        timestamp INTEGER NOT NULL
                    )
                    """.trimIndent()
                )
                db.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS downloaded_songs (
                        id TEXT NOT NULL PRIMARY KEY,
                        trackName TEXT NOT NULL,
                        artistName TEXT NOT NULL,
                        provider TEXT NOT NULL,
                        totalTokens INTEGER NOT NULL,
                        matchedWordsJson TEXT NOT NULL,
                        timestamp INTEGER NOT NULL
                    )
                    """.trimIndent()
                )
            }
        }
    }
}
