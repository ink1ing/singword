package com.singword.app.domain

data class MatchedWord(
    val word: String,
    val pos: String,
    val def: String,
    val source: String  // e.g. "CET-4", "CET-6", "IELTS", "TOEFL"
)
