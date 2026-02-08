import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final vehicleNo = '58마6661';
  final path = '/api/vehicles/$vehicleNo';
  
  // Headers provided in previous sessions
  final headers = {
    'X-Apt-Code': 'A0001',
    'X-Bouncer-Code': 'B000',
    'X-Device-Id': 'abdc60ab-3546-4573-a2d3-ede15a79da98',
    'X-App-Version': '0.0.1',
  };

  print('Testing GET $path');
  print('Headers: $headers');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${utf8.decode(response.bodyBytes)}');
    
    if (response.statusCode == 200) {
      print('Success!');
    } else {
      print('Failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
