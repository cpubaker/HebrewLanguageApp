package com.nedash.hebrewlanguageapp

import android.media.AudioManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        volumeControlStream = AudioManager.STREAM_MUSIC
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.nedash.hebrewlanguageapp/audio_output"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isMediaVolumeMuted" -> {
                    val audioManager = getSystemService(AUDIO_SERVICE) as? AudioManager
                    val currentVolume =
                        audioManager?.getStreamVolume(AudioManager.STREAM_MUSIC)
                    result.success(currentVolume != null && currentVolume <= 0)
                }

                else -> result.notImplemented()
            }
        }
    }
}
