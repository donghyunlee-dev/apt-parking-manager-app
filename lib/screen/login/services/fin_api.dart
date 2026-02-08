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
          
    final Map<String, dynamic> data = response.containsKey('payload') ? response['payload'] : response;
          
    if (data.isEmpty) {
          return null;
        }

    debugPrint('Bouncer Data: $data');     
    return Bouncer.fromJson(data);
  }
}
