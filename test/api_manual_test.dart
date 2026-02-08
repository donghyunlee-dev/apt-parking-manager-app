import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://apt-parking-manager.onrender.com';
  final path = '/api/apartment';
  final address = '대한민국 인천광역시 남동구 만수3동 844-7'; 
  
  final uri = Uri.parse('$baseUrl$path?address=$address');
  print('Requesting: $uri');
  
  try {
    final response = await http.get(uri);
    print('Status Code: ${response.statusCode}');
    print('Raw Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Decoded JSON: $json');
      
      final data = json.containsKey('payload') ? json['payload'] : json;
      if (data != null && data is Map) {
        final code = data['code'] ?? data['apt_code'];
        print('Apt Code Found: $code');
        
        if (code == 'A0001') {
          print('SUCCESS: Found A0001!');
        } else {
          print('FAILURE: Code is $code, not A0001');
        }
      } else {
        print('Data is null or not a map: $data');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}
