import '../../../models/searched_vehicle.dart';
import '../../../models/vehicle_response.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sessions/session_context.dart';

class SearchVehicleApi {
  static Future<VehicleResponse<SearchedVehicle?>> search({
    required String vehicleNo,
    required SessionContext sessionContext,
  }) async {
    final response = await ApiClient.get(
      path: '/api/vehicles/$vehicleNo', // Updated URI
      headers: sessionContext.headers,
    );

    return VehicleResponse.fromJson(
      response,
      (json) {
        if (json != null && json is Map<String, dynamic>) {
          return SearchedVehicle.fromJson(json);
        }
        return null;
      },
    );
  }
}
