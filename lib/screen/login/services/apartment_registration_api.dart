import '../../../core/network/api_client.dart';
import '../../../models/apartment.dart';

class ApartmentRegistrationApi {
  /// 아파트 등록 API
  /// bouncer 계정이 자동으로 생성되므로 finCode가 필수입니다.
  static Future<Map<String, dynamic>> register({
    required String aptName,
    required String address,
    required int building,
    required int resident,
    required String finNo,
    required String deviceId,
  }) async {
    try {
      final response = await ApiClient.post(
        path: '/api/apartment',
        body: {
          'apt_name': aptName,
          'address': address,
          'building': building,
          'resident': resident,
          'fin_no': finNo,
          'device_id': deviceId,
        },
      );

      // 서버 응답에서 생성된 아파트 정보 반환
      // 응답 구조: { "payload": { "apt_code": "A0001", ... } }
      if (response['payload'] != null) {
        return response['payload'] as Map<String, dynamic>;
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
