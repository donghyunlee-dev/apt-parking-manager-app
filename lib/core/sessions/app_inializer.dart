import 'package:flutter/foundation.dart';
import 'session_storage.dart';
import 'app_init_result.dart';
import '../devices/device_id_provider.dart';
import '../utils/location_service.dart';
import '../../screen/login/services/apartment_api.dart';

class AppInitializer {
  final SessionStorage sessionStorage;
  final DeviceIdProvider deviceIdProvider;
  final LocationService locationService;

  AppInitializer({
    required this.sessionStorage,
    required this.deviceIdProvider,
    required this.locationService,
  });

  Future<AppInitResult> initialize() async {
    final session = await sessionStorage.load();

    if (session != null) {
      final now = DateTime.now();
      final diff = now.difference(session.createdAt);
      
      // 1. 세션 만료 체크 (24시간)
      if (diff.inHours >= 24) {
        debugPrint('🕒 Session expired (24h+). Clearing.');
        await sessionStorage.clear();
        return _needLogin();
      }
      
      // 2. 위치 정보 기반 아파트 검증
      final address = await locationService.getCurrentAddress();
      if (address != null) {
        final apt = await ApartmentApi.findByAddress(address);
        if (apt == null || apt.code != session.aptCode) {
          debugPrint('📍 Location mismatch or no apartment found. Clearing session.');
          await sessionStorage.clear();
          return _needLogin();
        }
      }
      
      return AppInitReady(session);
    }

    return _needLogin();
  }

  Future<AppInitResult> _needLogin() async {
    final deviceId = await deviceIdProvider.getOrCreate();
    return AppInitNeedLogin(deviceId);
  }
}