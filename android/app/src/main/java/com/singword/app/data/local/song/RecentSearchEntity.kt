package com.singword.app.data.local.song

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "recent_searches")
data class RecentSearchEntity(
    @PrimaryKey val id: String,
    val trackName: String,
    val artistName: String,
    val provider: String,
    val totalTokens: Int,
    val matchedWordsJson: String,
    val timestamp: Long
)
