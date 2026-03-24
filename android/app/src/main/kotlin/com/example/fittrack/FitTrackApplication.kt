package com.vncntvx.fittrack

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class FitTrackApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        ensureForegroundServiceChannels()
    }

    private fun ensureForegroundServiceChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        val manager = getSystemService(NotificationManager::class.java) ?: return
        val channelName = "Background Service"
        val channelDescription = "Executing process in background"

        listOf("fittrack_service", "FOREGROUND_DEFAULT").forEach { channelId ->
            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_LOW,
            ).apply {
                description = channelDescription
            }
            manager.createNotificationChannel(channel)
        }
    }
}
