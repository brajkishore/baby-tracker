package com.example.baby_tracker

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel

class ScreenStateReceiver(private val events: EventChannel.EventSink? = null) : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            Intent.ACTION_SCREEN_ON -> events?.success("ON")
            Intent.ACTION_SCREEN_OFF -> events?.success("OFF")
        }
    }
}
