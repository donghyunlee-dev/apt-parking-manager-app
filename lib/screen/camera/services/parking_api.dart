import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../models/parking_vehicle.dart';
import '../../../core/sessions/session_context.dart';

class ParkingApi {

    static Future<ParkingVehicle> getVehicle(String vehicleNo, SessionContext sessionContext) async {
        final json = await ApiClient.get(
          path: '/api/vehicles/parking',
          query: {'vehicle_no': vehicleNo},
          headers: sessionContext.headers,
        );
        debugPrint('API Result: $json');
        
        // The parking API returns the data directly or in json itself
        if (json is! Map<String, dynamic> || json.isEmpty) {
          throw Exception('조회된 차량 정보가 없습니다.');
        }
        
        // If there is no 'vehicle_no' in root, it's likely empty or error
        if (!json.containsKey('vehicle_no')) {
           throw Exception('조회된 차량 정보가 없습니다.');
        }

        return ParkingVehicle.fromJson(json);
    }
}