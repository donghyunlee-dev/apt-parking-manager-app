import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final vehicleNo = '58마6665';
  final path = '/api/vehicles/parking';
  
  final headers = {
    'X-Apt-Code': 'A0001',
    'X-Bouncer-Code': 'B000',
    'X-Device-Id': 'abdc60ab-3546-4573-a2d3-ede15a79da98',
    'X-App-Version': '0.0.1',
  };

  final uri = Uri.parse('$baseUrl$path').replace(queryParameters: {'vehicle_no': vehicleNo});
  print('Testing GET $uri');

  try {
    final response = await http.get(
      uri,
      headers: headers,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${utf8.decode(response.bodyBytes)}');
  } catch (e) {
    print('Error: $e');
  }
}
