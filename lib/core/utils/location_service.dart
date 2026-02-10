import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class LocationService {
  static const String _kakaoApiKey = '8954cca8dc3fd84fe637c56de4a5b73f'; // 네이티브 키로 업데이트

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

      return await _getAddressFromKakao(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Location Error: $e');
      return null;
    }
  }

  static const platform = MethodChannel('apt_parking/location');
  String? _cachedKeyHash;

  Future<String?> _getAddressFromKakao(double lat, double lng) async {
    final url = Uri.parse(
        'https://dapi.kakao.com/v2/local/geo/coord2address.json?x=$lng&y=$lat&input_coord=WGS84');

    // Android의 경우 실제 키 해시를 가져옴
    if (_cachedKeyHash == null && Platform.isAndroid) {
      try {
        _cachedKeyHash = await platform.invokeMethod('getKeyHash');
        debugPrint('**************************************');
        debugPrint('실제 앱 키 해시: $_cachedKeyHash');
        debugPrint('**************************************');
      } catch (e) {
        debugPrint('키 해시 가져오기 실패: $e');
      }
    }

    // KA 헤더 구성: origin에 패키지명 대신 실제 키 해시를 넣어야 하는 경우가 있음
    final String os = Platform.isAndroid ? 'android' : 'ios';
    final String origin = Platform.isAndroid 
        ? (_cachedKeyHash ?? 'com.windsoft.apt_parking_manager') 
        : 'com.windsoft.aptParkingManager';
    
    final String kaHeader = 'sdk/1.0.0 os/$os lang/ko-KR origin/$origin';

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'KakaoAK $_kakaoApiKey',
          'KA': kaHeader,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List;

        if (documents.isNotEmpty) {
          final doc = documents.first;
          
          // 지번 주소를 우선적으로 사용 (사용자 요청: 지번 주소 우선)
          if (doc['address'] != null) {
            return doc['address']['address_name'];
          } 
          // 지번 주소가 없는 경우 도로명 주소 사용
          else if (doc['road_address'] != null) {
            return doc['road_address']['address_name'];
          }
        }
      } else {
        debugPrint('Kakao API Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('Kakao API Exception: $e');
    }
    return null;
  }
}
