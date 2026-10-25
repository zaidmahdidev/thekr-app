package com.example.thekr_app.radio

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * The line between the radio screen (Dart) and its media notification.
 *
 * Dart sends `show` / `hide`; the notification buttons send commands back
 * (`play`, `pause`, `next`, `previous`, `stop`). Nothing here knows about the
 * Quran player: the radio has a media session of its own.
 */
object RadioChannel {
    private const val NAME = "com.zaid.thekr_app/radio"

    private var channel: MethodChannel? = null
    private val main = Handler(Looper.getMainLooper())

    fun attach(context: Context, messenger: BinaryMessenger) {
        val app = context.applicationContext
        val next = MethodChannel(messenger, NAME)
        next.setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> try {
                    RadioPlaybackService.show(
                        app,
                        call.argument<String>("title") ?: "",
                        call.argument<String>("subtitle") ?: "",
                        call.argument<String>("state") ?: "playing",
                    )
                    result.success(null)
                } catch (e: Exception) {
                    // Dart then falls back to a plain notification.
                    result.error("radio_show_failed", e.message, null)
                }
                "hide" -> {
                    RadioPlaybackService.hide(app)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        channel = next
    }

    /** Hands a button press of the notification to the radio screen. */
    fun send(command: String) {
        main.post { channel?.invokeMethod("command", command) }
    }
}
