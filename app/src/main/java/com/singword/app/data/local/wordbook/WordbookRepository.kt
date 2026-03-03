package com.singword.app.data.local.wordbook

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import java.io.FileNotFoundException

class WordbookRepository(private val context: Context) {

    private val cache = mutableMapOf<String, Map<String, WordEntry>>()

    fun loadWordbook(meta: WordbookMeta): WordbookLoadResult {
        cache[meta.assetName]?.let { cached ->
            return WordbookLoadResult.Success(
                cached.mapValues { (_, entry) -> entry to meta.label }
            )
        }

        val assetPath = "wordbooks/${meta.assetName}.json"
        val json = try {
            context.assets.open(assetPath).bufferedReader().use { it.readText() }
        } catch (e: Exception) {
            if (e is FileNotFoundException || e.message?.contains("No such file", ignoreCase = true) == true) {
                return WordbookLoadResult.MissingAsset(assetPath)
            }
            return WordbookLoadResult.ParseError(assetPath, e.message ?: "无法读取词表")
        }

        return try {
            val type = object : TypeToken<List<WordEntry>>() {}.type
            val words: List<WordEntry> = Gson().fromJson(json, type)
            val map = words.associateBy { it.word.lowercase() }
            cache[meta.assetName] = map
            WordbookLoadResult.Success(map.mapValues { (_, entry) -> entry to meta.label })
        } catch (e: Exception) {
            WordbookLoadResult.ParseError(assetPath, e.message ?: "词表解析失败")
        }
    }

    fun loadEnabledWordbooks(enabled: List<WordbookId>): WordbookLoadResult {
        val result = mutableMapOf<String, Pair<WordEntry, String>>()
        for (id in enabled) {
            when (val loadResult = loadWordbook(WordbookCatalog.metaFor(id))) {
                is WordbookLoadResult.Success -> {
                    for ((word, pair) in loadResult.words) {
                        if (word !in result) {
                            result[word] = pair
                        }
                    }
                }
                is WordbookLoadResult.MissingAsset -> return loadResult
                is WordbookLoadResult.ParseError -> return loadResult
            }
        }
        return WordbookLoadResult.Success(result)
    }
}
