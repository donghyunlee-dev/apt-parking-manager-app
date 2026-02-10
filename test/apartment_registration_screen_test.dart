import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:apt_parking_manager/screen/login/apartment_registration_screen.dart';
import 'package:apt_parking_manager/core/devices/device_id_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeDeviceIdProvider extends DeviceIdProvider {
  FakeDeviceIdProvider() : super(const FlutterSecureStorage());

  @override
  Future<String> getOrCreate() async {
    return 'test-device-id';
  }
}

void main() {
  group('ApartmentRegistrationScreen', () {
    testWidgets('화면에 필수 입력 필드가 모두 표시되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DeviceIdProvider>.value(value: FakeDeviceIdProvider()),
          ],
          child: const MaterialApp(
            home: ApartmentRegistrationScreen(),
          ),
        ),
      );

      // 아파트 이름 필드
      expect(find.text('아파트 이름'), findsOneWidget);
      
      // 주소 필드
      expect(find.text('주소'), findsOneWidget);
      
      // 동 수 필드
      expect(find.text('동 수'), findsOneWidget);
      
      // 세대 수 필드
      expect(find.text('세대 수'), findsOneWidget);
      
      // FIN 번호 필드
      expect(find.text('FIN 번호(6자리 숫자)'), findsOneWidget);
      
      // FIN 번호 확인 필드
      expect(find.text('FIN 번호 확인'), findsOneWidget);
      
      // 등록 버튼
      expect(find.text('아파트 등록하기'), findsOneWidget);
    });

    testWidgets('FIN 번호가 일치하지 않으면 에러 메시지가 표시되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DeviceIdProvider>.value(value: FakeDeviceIdProvider()),
          ],
          child: const MaterialApp(
            home: ApartmentRegistrationScreen(),
          ),
        ),
      );

      // 아파트 정보 입력
      await tester.enterText(find.widgetWithText(TextFormField, '아파트 이름'), '테스트아파트');
      await tester.enterText(find.widgetWithText(TextFormField, '주소'), '서울시 강남구');
      await tester.enterText(find.widgetWithText(TextFormField, '동 수'), '10');
      await tester.enterText(find.widgetWithText(TextFormField, '세대 수'), '500');
      
      // FIN 번호 입력 (서로 다른 값)
      final finFields = find.byType(TextFormField);
      await tester.enterText(finFields.at(4), '123456'); // FIN 번호
      await tester.enterText(finFields.at(5), '654321'); // FIN 번호 확인 (다른 값)

      // 등록 버튼 클릭
      await tester.ensureVisible(find.text('아파트 등록하기'));
      await tester.tap(find.text('아파트 등록하기'));
      await tester.pump();

      // 에러 메시지 확인
      expect(find.text('불일치'), findsOneWidget);
    });

    testWidgets('FIN 번호가 6자리가 아니면 에러 메시지가 표시되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DeviceIdProvider>.value(value: FakeDeviceIdProvider()),
          ],
          child: const MaterialApp(
            home: ApartmentRegistrationScreen(),
          ),
        ),
      );

      // 아파트 정보 입력
      await tester.enterText(find.widgetWithText(TextFormField, '아파트 이름'), '테스트아파트');
      await tester.enterText(find.widgetWithText(TextFormField, '주소'), '서울시 강남구');
      await tester.enterText(find.widgetWithText(TextFormField, '동 수'), '10');
      await tester.enterText(find.widgetWithText(TextFormField, '세대 수'), '500');
      
      // FIN 번호 입력 (5자리)
      final finFields = find.byType(TextFormField);
      await tester.enterText(finFields.at(4), '12345'); // 5자리
      await tester.enterText(finFields.at(5), '12345');

      // 등록 버튼 클릭
      await tester.ensureVisible(find.text('아파트 등록하기'));
      await tester.tap(find.text('아파트 등록하기'));
      await tester.pump();

      // 에러 메시지 확인 (FIN 번호와 FIN 번호 확인 필드 모두에 표시됨)
      expect(find.text('6자리'), findsWidgets);
    });

    testWidgets('모든 필드가 올바르게 입력되면 폼 검증이 통과되는지 확인', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<DeviceIdProvider>.value(value: FakeDeviceIdProvider()),
          ],
          child: MaterialApp(
            home: const ApartmentRegistrationScreen(),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login Screen')),
            },
          ),
        ),
      );

      // 아파트 정보 입력
      await tester.enterText(find.widgetWithText(TextFormField, '아파트 이름'), '테스트아파트');
      await tester.enterText(find.widgetWithText(TextFormField, '주소'), '서울시 강남구');
      await tester.enterText(find.widgetWithText(TextFormField, '동 수'), '10');
      await tester.enterText(find.widgetWithText(TextFormField, '세대 수'), '500');
      
      // FIN 번호 입력 (일치하는 6자리)
      final finFields = find.byType(TextFormField);
      await tester.enterText(finFields.at(4), '123456');
      await tester.enterText(finFields.at(5), '123456');

      // 등록 버튼 클릭
      await tester.ensureVisible(find.text('아파트 등록하기'));
      await tester.tap(find.text('아파트 등록하기'));
      await tester.pump();

      // 에러 메시지가 없어야 함
      expect(find.text('불일치'), findsNothing);
      expect(find.text('6자리'), findsNothing);
    });
  });
}
