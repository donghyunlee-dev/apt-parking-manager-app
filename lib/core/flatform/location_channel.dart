import 'package:flutter/services.dart';

class LocationChannel {
  static const MethodChannel _channel = MethodChannel('apt_parking/location');

  static Future<String?> getCurrentAddress() async {
      final result = await _channel.invokeMethod<String>('getAddress');
      return result;
  }
}