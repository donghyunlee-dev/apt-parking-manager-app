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
        print('json : $json');
        return ParkingVehicle.fromJson(json);
    }
}