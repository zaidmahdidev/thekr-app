package com.example.thekr_app.radio

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** Receives the buttons of the radio notification and passes them on. */
class RadioActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val command = intent.getStringExtra(EXTRA_COMMAND) ?: return
        RadioChannel.send(command)
    }

    companion object {
        const val ACTION = "com.example.thekr_app.radio.COMMAND"
        const val EXTRA_COMMAND = "command"
    }
}
