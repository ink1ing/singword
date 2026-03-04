package com.singword.app.data.remote

import retrofit2.http.GET
import retrofit2.http.Query

interface LrclibApi {

    @GET("api/search")
    suspend fun search(@Query("q") query: String): List<LrclibTrack>
}
