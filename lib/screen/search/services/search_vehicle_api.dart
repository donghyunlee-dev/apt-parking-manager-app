import '../../../models/searched_vehicle.dart';
import '../../../models/vehicle_response.dart';
import '../../../core/network/api_client.dart';
import '../../../core/sessions/session_context.dart';

class SearchVehicleApi {
  static Future<VehicleResponse<List<SearchedVehicle>>> search({
    required String vehicleNo,
    required SessionContext sessionContext,
  }) async {
    final response = await ApiClient.get(
      path: '/api/vehicles/search', // Placeholder URI
      queryParams: {'vehicle_no': vehicleNo},
      headers: sessionContext.headers,
    );

    return VehicleResponse.fromJson(
      response,
      (json) {
        if (json is List) {
          return json.map((item) => SearchedVehicle.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      },
    );
  }
}
