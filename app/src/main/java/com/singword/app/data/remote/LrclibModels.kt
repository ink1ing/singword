package com.singword.app.data.remote

import com.google.gson.annotations.SerializedName

data class LrclibTrack(
    val id: Int,
    @SerializedName("trackName")  val trackName: String?,
    @SerializedName("artistName") val artistName: String?,
    @SerializedName("albumName")  val albumName: String?,
    val duration: Int?,
    @SerializedName("plainLyrics")  val plainLyrics: String?,
    @SerializedName("syncedLyrics") val syncedLyrics: String?
)
