import '../../../core/network/api_client.dart';
import '../../../models/apartment.dart';

class ApartmentApi {

    static Future<Apartment?> findByAddress(String address) async {
        final json = await ApiClient.get('/api/apartment', {'address': address});

        if (json.isEmpty) {
            return null;
        }

        return Apartment.fromJson(json);
    }
}