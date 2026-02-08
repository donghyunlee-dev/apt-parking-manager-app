import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final aptCode = 'A0001';
  final pin = '123456'; // Dummy PIN
  final deviceId = 'abdc60ab-3546-4573-a2d3-ede15a79da98';
  
  print('Testing PIN Verify: $pin for Apt: $aptCode');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/access'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'apt_code': aptCode,
        'fin_code': pin,
        'device_id': deviceId,
        'location': '인천광역시 남동구'
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${utf8.decode(response.bodyBytes)}');
  } catch (e) {
    print('Error: $e');
  }
}
