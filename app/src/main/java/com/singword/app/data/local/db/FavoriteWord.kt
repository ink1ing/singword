package com.singword.app.data.local.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "favorites")
data class FavoriteWord(
    // Unique by word globally: same token across wordbooks keeps first starred meaning.
    @PrimaryKey val word: String,
    val pos: String,
    val def: String,
    val source: String,
    val timestamp: Long = System.currentTimeMillis()
)
