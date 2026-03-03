package com.singword.app.data.local.db

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface FavoriteDao {

    @Query("SELECT * FROM favorites ORDER BY timestamp DESC")
    fun getAll(): Flow<List<FavoriteWord>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(word: FavoriteWord)

    @Delete
    suspend fun delete(word: FavoriteWord)

    @Query("SELECT word FROM favorites")
    fun getAllWords(): Flow<List<String>>
}
