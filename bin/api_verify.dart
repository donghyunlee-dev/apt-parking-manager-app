import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://apt-parking-manager.onrender.com';
const String testAptCode = 'APT001'; // Replace with real test code if known
const String testDeviceId = 'TEST_DEVICE_ID';

void main() async {
  print('--- Starting API Verification ---');

  // 0. Discovery Test
  print('\n--- Discovery Tests ---');
  await testApi('List all apartments (guess)', () async {
    return await http.get(Uri.parse('$baseUrl/api/apartments'));
  });

  // 1. Test Apartment Search (More variations)
  print('\n--- Apartment Search Tests ---');
  final addresses = [
    '대한민국 인천광역시 남동구 만수3동 844-7',
    '인천광역시 남동구 만수3동 844-7',
    '만수3동 844-7',
    '만수동 844-7',
  ];
  for (var addr in addresses) {
    await testApi('Search by: $addr', () async {
      return await http.get(Uri.parse('$baseUrl/api/apartment?address=${Uri.encodeComponent(addr)}'));
    });
  }

  // 2. Test Login/FIN Verify with various PINs
  print('\n--- FIN Verification Tests ---');
  final pins = ['123456', '000000', '111111'];
  for (var pin in pins) {
    await testApi('PIN: $pin', () async {
      final body = {
        'apt_code': testAptCode,
        'fin_code': pin,
        'device_id': testDeviceId,
        'location': '서울'
      };
      return await http.post(
        Uri.parse('$baseUrl/api/access'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    });
  }

  // 3. Check /api/notices again with more detail
  print('\n--- Notice API Check ---');
  await testApi('Fetch Notices (Detailed)', () async {
    return await http.get(
      Uri.parse('$baseUrl/api/notices'),
      headers: {
        'X-Device-Id': testDeviceId,
        'X-Apt-Code': testAptCode,
        'X-Bouncer-Code': 'TEST_BOUNCER',
        'X-App-Version': '0.0.1',
      },
    );
  });

  print('--- API Verification Completed ---');
}

Future<void> testApi(String name, Future<http.Response> Function() call) async {
  print('\nTesting: $name');
  try {
    final res = await call();
    print('Status: ${res.statusCode}');
    print('Body: ${res.body}');
  } catch (e) {
    print('Error: $e');
  }
}
