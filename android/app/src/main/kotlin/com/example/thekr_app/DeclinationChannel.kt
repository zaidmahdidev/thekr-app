package com.example.thekr_app

import android.hardware.GeomagneticField
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * The angle between magnetic north (what a phone compass shows) and true north
 * at a place, from Android's own World Magnetic Model. The Qibla bearing is
 * measured from true north, so the compass needs this correction.
 */
object DeclinationChannel {
    fun attach(messenger: BinaryMessenger) {
        MethodChannel(messenger, "thekr/declination").setMethodCallHandler { call, result ->
            if (call.method != "declination") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val lat = call.argument<Double>("lat")
            val lng = call.argument<Double>("lng")
            if (lat == null || lng == null) {
                result.error("bad_args", "lat and lng are required", null)
                return@setMethodCallHandler
            }
            val altitude = call.argument<Double>("altitude") ?: 0.0
            val field = GeomagneticField(
                lat.toFloat(), lng.toFloat(), altitude.toFloat(), System.currentTimeMillis()
            )
            result.success(field.declination.toDouble())
        }
    }
}
