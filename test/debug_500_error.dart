import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> main() async {
  const baseUrl = 'https://apt-parking-manager.onrender.com';
  const path = '/api/apartment';
  
  final addresses = [
    '인천 남동구 만수동 844-1', // 사용자 제보 (500 에러)
    '서울시 강남구 테스트동 123', // 제가 등록한 데이터
    '서판로 30', // Postman 예제
    '대한민국 인천광역시 남동구 만수3동 844-7', // Postman 예제
  ];

  for (final address in addresses) {
    print('\nTesting address: $address');
    final query = {'address': address};
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    
    try {
      final response = await http.get(uri);
      print('Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        print('Body: ${utf8.decode(response.bodyBytes)}');
      } else {
        print('Success! Body prefix: ${utf8.decode(response.bodyBytes).substring(0, 50)}...');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
