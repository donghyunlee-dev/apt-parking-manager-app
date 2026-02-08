import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final path = '/api/vehicles/visitors';
  
  // Headers provided by user
  final headers = {
    'Content-Type': 'application/json',
    'X-Apt-Code': 'A0001',
    'X-Bouncer-Code': 'B000',
    'X-Device-Id': 'abdc60ab-3546-4573-a2d3-ede15a79da98',
    'X-App-Version': '0.0.1',
  };

  // Visitor Body provided by user
  final body = {
    "vehicle_no": "125가1253",
    "bd_id": "1동",
    "bd_unit": "402호",
    "phone": "010-2342-5123",
    "visit_date": "2026-01-28",
    "visit_time": "12:34",
    "visit_close_date": "2026-01-29",
    "memo": "방문증"
  };

  print('Testing POST $path');
  print('Headers: $headers');
  print('Body: $body');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      print('Success!');
    } else {
      print('Failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
