package com.singword.app

import android.app.Application
import com.singword.app.di.AppContainer

class SingWordApp : Application() {

    lateinit var container: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()
        container = AppContainer(this)
    }
}
