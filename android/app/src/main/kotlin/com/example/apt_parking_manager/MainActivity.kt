package com.example.apt_parking_manager

import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.location.Geocoder
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.google.android.gms.location.LocationServices
import java.util.Locale
import com.google.android.gms.location.Priority
import android.location.Location

class MainActivity : FlutterActivity() {

    private val CHANNEL = "apt_parking/location"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->

            if (call.method == "getAddress") {
                
                if (!hasLocationPermission()) {
                    result.error(
                        "PERMISSION",
                        "Location permission not granted",
                        null
                    )
                    return@setMethodCallHandler
                }

                requestCurrentLocation(result)
                 
            } else {
                result.notImplemented()
            }
        }
    }

    private fun requestCurrentLocation(result: MethodChannel.Result) {

    val fusedLocationClient =
        LocationServices.getFusedLocationProviderClient(this)

    fusedLocationClient
        .getCurrentLocation(Priority.PRIORITY_HIGH_ACCURACY, null)
        .addOnSuccessListener { location ->

            if (location == null) {
                result.success("위치 정보를 가져올 수 없습니다")
                return@addOnSuccessListener
            }

            val lat = location.latitude
            val lng = location.longitude

            val geocoder = Geocoder(this, Locale.KOREA)

            try {
                val addresses = geocoder.getFromLocation(lat, lng, 1)

                val address = if (!addresses.isNullOrEmpty()) {
                    addresses[0].getAddressLine(0)
                } else {
                    "주소를 찾을 수 없습니다"
                }

                // ✅ success는 여기서 단 1회
                result.success(address)

            } catch (e: Exception) {
                result.error(
                    "GEOCODER_ERROR",
                    e.message,
                    null
                )
            }
        }
        .addOnFailureListener { e ->
            result.error(
                "LOCATION_FAILED",
                e.message,
                null
            )
        }
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }  
}