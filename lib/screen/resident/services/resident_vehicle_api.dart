import '../../../models/vehicle_response.dart';
import '../../../models/resident_vehicle.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sessions/session_context.dart';

class ResidentVehicleApi {
  static Future<VehicleResponse<ResidentVehicle>> register({
    required String vehicleNo,
    required String bdId,
    required String bdUnit,
    required String phone,
    required String memo,
    required SessionContext sessionContext,
  }) async {
    final response = await ApiClient.post(
      path: '/api/vehicles/residents',
      body: {
        'vehicle_no': vehicleNo,
        'bd_id': bdId,
        'bd_unit': bdUnit,
        'phone': phone,
        'memo': memo,
      },
      headers: sessionContext.headers, 

    );

    return VehicleResponse.fromJson(
      response,
      (json) => ResidentVehicle.fromJson(json as Map<String, dynamic>),
    );
  }
}
