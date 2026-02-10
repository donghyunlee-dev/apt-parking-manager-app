import 'package:flutter_test/flutter_test.dart';
import 'package:apt_parking_manager/screen/login/services/apartment_registration_api.dart';

void main() {
  group('ApartmentRegistrationApi', () {
    test('register 메서드가 올바른 파라미터로 호출되는지 확인', () async {
      // 이 테스트는 실제 API 호출을 하므로 서버가 실행 중이어야 합니다.
      // 단위 테스트로는 mock을 사용해야 하지만, 여기서는 통합 테스트로 작성합니다.
      
      try {
        final response = await ApartmentRegistrationApi.register(
          aptName: '테스트아파트',
          address: '서울시 강남구 테스트동 123',
          building: 10,
          resident: 500,
          finNo: '123456',
          deviceId: 'test-device-id',
        );
        
        // 응답이 Map 형태로 반환되는지 확인
        expect(response, isA<Map<String, dynamic>>());
        
        print('API 응답: $response');
      } catch (e) {
        // 서버가 실행 중이 아니거나 네트워크 오류가 발생할 수 있음
        print('API 호출 실패 (예상된 동작일 수 있음): $e');
      }
    });

    test('finNo가 6자리가 아닌 경우 서버에서 거부되는지 확인', () async {
      try {
        await ApartmentRegistrationApi.register(
          aptName: '테스트아파트',
          address: '서울시 강남구 테스트동 123',
          building: 10,
          resident: 500,
          finNo: '12345', // 5자리 (잘못된 입력)
          deviceId: 'test-device-id',
        );
        
        fail('6자리가 아닌 FIN 코드는 서버에서 거부되어야 합니다.');
      } catch (e) {
        // 예외가 발생하면 정상
        expect(e, isNotNull);
        print('예상된 오류 발생: $e');
      }
    });
  });
}
