import '../../../core/network/api_client.dart';
import '../../../models/apartment.dart';

class ApartmentApi {

    static Future<Apartment?> findByAddress(String address) async {
        final json = await ApiClient.get(path: '/api/apartment', query: {'address': address});

        if (json.isEmpty) {
            return null;
        }

        return Apartment.fromJson(json);
    }
}