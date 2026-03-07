package com.singword.app.data.local.song

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface RecentSearchDao {
    @Query("SELECT * FROM recent_searches ORDER BY timestamp DESC LIMIT 3")
    fun getAll(): Flow<List<RecentSearchEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(item: RecentSearchEntity)

    @Query(
        """
        DELETE FROM recent_searches 
        WHERE id NOT IN (
            SELECT id FROM recent_searches ORDER BY timestamp DESC LIMIT 3
        )
        """
    )
    suspend fun trimToLatestThree()
}
