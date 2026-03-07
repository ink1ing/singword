package com.singword.app.data.local.song

import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class DownloadedSongRepository(
    private val dao: DownloadedSongDao
) {
    fun getAll(): Flow<List<SongMatchSnapshot>> = dao.getAll().map { items ->
        items.map { entity ->
            SongMatchSnapshot(
                id = entity.id,
                trackName = entity.trackName,
                artistName = entity.artistName,
                provider = entity.provider,
                totalTokens = entity.totalTokens,
                matchedWords = SongSnapshotCodec.decode(entity.matchedWordsJson),
                timestamp = entity.timestamp
            )
        }
    }

    fun getAllIds(): Flow<List<String>> = dao.getAllIds()

    suspend fun upsert(snapshot: SongMatchSnapshot) {
        dao.insert(
            DownloadedSongEntity(
                id = snapshot.id,
                trackName = snapshot.trackName,
                artistName = snapshot.artistName,
                provider = snapshot.provider,
                totalTokens = snapshot.totalTokens,
                matchedWordsJson = SongSnapshotCodec.encode(snapshot.matchedWords),
                timestamp = snapshot.timestamp
            )
        )
    }

    suspend fun delete(snapshot: SongMatchSnapshot) {
        dao.delete(
            DownloadedSongEntity(
                id = snapshot.id,
                trackName = snapshot.trackName,
                artistName = snapshot.artistName,
                provider = snapshot.provider,
                totalTokens = snapshot.totalTokens,
                matchedWordsJson = SongSnapshotCodec.encode(snapshot.matchedWords),
                timestamp = snapshot.timestamp
            )
        )
    }
}
