package com.windsoft.apt_parking_manager

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
import android.util.Base64
import android.util.Log
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 앱 시작 시 로그에 출력 (보조용)
        printKeyHash()
    }

    private val CHANNEL = "apt_parking/location"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        .setMethodCallHandler { call, result ->
            if (call.method == "getAddress") {
                if (!hasLocationPermission()) {
                    result.error("PERMISSION", "Location permission not granted", null)
                    return@setMethodCallHandler
                }
                requestCurrentLocation(result)
            } else if (call.method == "getKeyHash") {
                val hash = getKeyHash()
                if (hash != null) {
                    result.success(hash)
                } else {
                    result.error("HASH_ERROR", "Failed to get key hash", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun requestCurrentLocation(result: MethodChannel.Result) {
        val fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
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
                    result.success(address)
                } catch (e: Exception) {
                    result.error("GEOCODER_ERROR", e.message, null)
                }
            }
            .addOnFailureListener { e ->
                result.error("LOCATION_FAILED", e.message, null)
            }
    }

    private fun getKeyHash(): String? {
        try {
            val info = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
            }
            
            val signatures = if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.P) {
                info.signingInfo?.apkContentsSigners
            } else {
                @Suppress("DEPRECATION")
                info.signatures
            }

            if (signatures != null && signatures.isNotEmpty()) {
                val md = MessageDigest.getInstance("SHA")
                md.update(signatures[0].toByteArray())
                return Base64.encodeToString(md.digest(), Base64.NO_WRAP).trim()
            }
        } catch (e: Exception) {
            Log.e("KeyHash", "Error getting key hash", e)
        }
        return null
    }

    private fun printKeyHash() {
        val hash = getKeyHash()
        if (hash != null) {
            Log.e("KeyHash", "**************************************************")
            Log.e("KeyHash", "  카카오 등록용 키 해시: $hash")
            Log.e("KeyHash", "**************************************************")
        }
    }

    private fun hasLocationPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
    }  
}
