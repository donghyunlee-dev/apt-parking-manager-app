import '../../../models/vehicle_response.dart';
import '../../../models/visitor_vehicle.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sessions/session_context.dart';

class VisitorVehicleApi {
  static Future<VehicleResponse<VisitorVehicle>> register({
    required String vehicleNo,
    required String bdId,
    required String bdUnit,
    required String phone,
    required String visitDate,
    required String visitTime,
    required String visitCloseDate,
    required String memo,
    required SessionContext sessionContext,
  }) async {
    final response = await ApiClient.post(
      path: '/api/vehicles/visitors',
      body: {
        'vehicle_no': vehicleNo,
        'bd_id': bdId,
        'bd_unit': bdUnit,
        'phone': phone,
        'visit_date': visitDate,
        'visit_time': visitTime,
        'visit_close_date': visitCloseDate,
        'memo': memo,
      },
      headers: sessionContext.headers, 

    );

    return VehicleResponse.fromJson(
      response,
      (json) => VisitorVehicle.fromJson(json as Map<String, dynamic>),
    );
  }
}
