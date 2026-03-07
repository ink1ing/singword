package com.singword.app.data.local.song

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface DownloadedSongDao {
    @Query("SELECT * FROM downloaded_songs ORDER BY timestamp DESC")
    fun getAll(): Flow<List<DownloadedSongEntity>>

    @Query("SELECT id FROM downloaded_songs")
    fun getAllIds(): Flow<List<String>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(item: DownloadedSongEntity)

    @Delete
    suspend fun delete(item: DownloadedSongEntity)
}
