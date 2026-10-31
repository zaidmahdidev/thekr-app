package com.example.thekr_app

import com.example.thekr_app.radio.RadioChannel
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The radio's media notification talks to the radio screen here.
        RadioChannel.attach(applicationContext, flutterEngine.dartExecutor.binaryMessenger)
        // Magnetic north to true north, for the Qibla compass.
        DeclinationChannel.attach(flutterEngine.dartExecutor.binaryMessenger)
    }
}
