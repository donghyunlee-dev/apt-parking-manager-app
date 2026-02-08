import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  Future<String?> getCurrentAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        // 항목 리스트에서 null이나 빈 값을 제외하고 공백으로 연결
        final parts = [
          p.administrativeArea,
          p.locality,
          p.subLocality,
          p.thoroughfare,
          p.subThoroughfare,
        ].where((part) => part != null && part.isNotEmpty).toList();
        
        return parts.join(' ').trim();
      }
      return null;
    } catch (e) {
      debugPrint('Location Error: $e');
      return null;
    }
  }
}
