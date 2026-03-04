package com.singword.app.data.local.db

import kotlinx.coroutines.flow.Flow

class FavoriteRepository(
    private val dao: FavoriteDao
) {
    fun getAllFavorites(): Flow<List<FavoriteWord>> = dao.getAll()

    fun getAllFavoriteWords(): Flow<List<String>> = dao.getAllWords()

    suspend fun upsert(word: FavoriteWord) = dao.insert(word)

    suspend fun delete(word: FavoriteWord) = dao.delete(word)
}
