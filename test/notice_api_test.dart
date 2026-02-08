import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final path = '/api/notices';
  
  // Real headers would need a session
  final headers = {
    'X-Apt-Code': 'A0001',
    'X-Bouncer-Code': 'B000',
    'X-Device-Id': 'abdc60ab-3546-4573-a2d3-ede15a79da98',
    'X-App-Version': '0.0.1',
  };

  print('Testing GET $path');
  print('Headers: $headers');

  try {
    final queryParams = {'apt_code': 'A0001'};
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    print('Requesting: $uri');
    final response = await http.get(
      uri,
      headers: headers,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Decoded JSON: $json');
      if (json.containsKey('payload')) {
        print('Payload type: ${json['payload'].runtimeType}');
        print('Payload: ${json['payload']}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
