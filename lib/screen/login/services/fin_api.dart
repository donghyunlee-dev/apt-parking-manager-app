import 'package:apt_parking_manager/core/network/api_client.dart';
import '../../../models/bouncer.dart';
import 'package:flutter/foundation.dart';

class FinApi {
  static const String _basePath = '/api/access';
 
  Future<Bouncer?> verifyFin({
    required String aptCode,
    required String finCode,
    required String deviceId,
    required String location,
}) async {
    final response = await ApiClient.post(
      path: '$_basePath',
      body: {
        'apt_code': aptCode,
        'fin_code': finCode,
        'device_id': deviceId,
        'location': location,
      },
    );
          
    if (response.isEmpty) {
          return null;
        }

    debugPrint('response!!! = ${response}');     
    return Bouncer.fromJson(response);
  }
}
