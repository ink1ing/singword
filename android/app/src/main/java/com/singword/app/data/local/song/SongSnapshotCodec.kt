package com.singword.app.data.local.song

import org.json.JSONArray
import org.json.JSONObject

object SongSnapshotCodec {
    fun encode(words: List<SongWordSnapshot>): String {
        val array = JSONArray()
        words.forEach { word ->
            array.put(
                JSONObject()
                    .put("word", word.word)
                    .put("pos", word.pos)
                    .put("def", word.def)
                    .put("source", word.source)
            )
        }
        return array.toString()
    }

    fun decode(raw: String): List<SongWordSnapshot> {
        if (raw.isBlank()) return emptyList()
        val array = JSONArray(raw)
        return buildList {
            for (index in 0 until array.length()) {
                val item = array.optJSONObject(index) ?: continue
                add(
                    SongWordSnapshot(
                        word = item.optString("word"),
                        pos = item.optString("pos"),
                        def = item.optString("def"),
                        source = item.optString("source")
                    )
                )
            }
        }
    }
}
