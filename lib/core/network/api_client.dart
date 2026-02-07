import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class ApiClient {
  static const String baseUrl = 'https://apt-parking-manager.onrender.com';

  /// ✅ 기존 호출 방식 유지
  /// ApiClient.get('/path', {'q': '1'});
  /// ApiClient.get('/path', {'q': '1'}, headers: {...});
  static Future<Map<String, dynamic>> get({
    required String path,
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);

    debugPrint('API GET = $uri');

    final response = await http.get(uri, headers: _mergeHeaders(headers));

    _validate(response);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> post({
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    debugPrint('API POST = $uri');
    debugPrint('API BODY = {$body}');
    debugPrint('API HEADEER = {$headers}');
    final response = await http.post(
      uri,
      headers: _mergeHeaders(headers),
      body: body != null ? jsonEncode(body) : null,
    );

    _validate(response);

    return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
  }

  static Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };
  }

  static void _validate(http.Response response) {
    if (response.statusCode != 200) {
      debugPrint('API ERROR = ${response.body}');
      throw Exception('API 호출 실패 (${response.statusCode})');
    }
  }
}
