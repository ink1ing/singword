package com.singword.app.data.local.db

import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

class FavoriteDaoTest {
    private lateinit var db: AppDatabase
    private lateinit var dao: FavoriteDao

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<android.content.Context>()
        db = Room.inMemoryDatabaseBuilder(context, AppDatabase::class.java)
            .allowMainThreadQueries()
            .build()
        dao = db.favoriteDao()
    }

    @After
    fun teardown() {
        db.close()
    }

    @Test
    fun insertAndDelete() = runBlocking {
        val word = FavoriteWord("shape", "n.", "形状", "CET-4")
        dao.insert(word)
        assertEquals(1, dao.getAll().first().size)

        dao.delete(word)
        assertEquals(0, dao.getAll().first().size)
    }

    @Test
    fun replaceByPrimaryKey() = runBlocking {
        dao.insert(FavoriteWord("song", "n.", "歌曲", "CET-4", timestamp = 1))
        dao.insert(FavoriteWord("song", "n.", "歌曲-新释义", "IELTS", timestamp = 2))

        val items = dao.getAll().first()
        assertEquals(1, items.size)
        assertEquals("IELTS", items.first().source)
    }

    @Test
    fun orderedByTimestampDesc() = runBlocking {
        dao.insert(FavoriteWord("older", "n.", "旧", "CET-4", timestamp = 1))
        dao.insert(FavoriteWord("newer", "n.", "新", "CET-6", timestamp = 2))

        val items = dao.getAll().first()
        assertEquals(listOf("newer", "older"), items.map { it.word })
    }
}
