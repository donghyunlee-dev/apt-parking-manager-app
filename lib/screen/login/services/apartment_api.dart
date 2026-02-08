import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../models/apartment.dart';

class ApartmentApi {
  static String? lastRawResponse;

  static Future<Apartment?> findByAddress(String address) async {
    final json =
        await ApiClient.get(path: '/api/apartment', query: {'address': address});
    lastRawResponse = jsonEncode(json);

    final dynamic data =
        json.containsKey('payload') ? json['payload'] : json;

    if (data == null || data is! Map<String, dynamic> || data.isEmpty) {
      return null;
    }

    final code = data['code'] ?? data['apt_code'];
    if (code == null || code == "") {
      return null;
    }

    return Apartment.fromJson(data);
  }
}