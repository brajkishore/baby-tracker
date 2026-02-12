package com.example.baby_tracker

import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val channelName = "baby_tracker/screen_state"
    private var receiver: ScreenStateReceiver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    receiver = ScreenStateReceiver(events)
                    val filter = IntentFilter().apply {
                        addAction("android.intent.action.SCREEN_ON")
                        addAction("android.intent.action.SCREEN_OFF")
                    }
                    registerReceiver(receiver, filter)
                }

                override fun onCancel(arguments: Any?) {
                    receiver?.let { unregisterReceiver(it) }
                    receiver = null
                }
            })
    }
}
