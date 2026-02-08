import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final path = '/api/vehicles/residents';
  
  // Mock data for registration
  final body = {
    'apt_code': 'A0001',
    'bouncer_code': 'B001',
    'car_no': '12가3456',
    'bd_id': '101',
    'bd_loc': '1101',
    'phone': '010-1234-5678',
    'memo': '테스트',
    'used': 'Y',
  };
  
  // Real headers would need a session, but let's see what happens without or with mock headers
  final headers = {
    'Content-Type': 'application/json',
    'X-Apt-Code': 'A0001',
    'X-Bouncer-Code': 'B001', // Mock bouncer code
  };

  print('Testing POST $path');
  print('Body: $body');
  print('Headers: $headers');

  try {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Decoded JSON: $json');
      if (json.containsKey('payload')) {
        print('Payload: ${json['payload']}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
