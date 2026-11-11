package com.dijlah.alseraj

import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: AudioServiceActivity() {
    private val CHANNEL = "com.dijlah.alseraj/timezone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getTimeZone") {
                result.success(TimeZone.getDefault().id)
            } else {
                result.notImplemented()
            }
        }
    }
}
