import 'session_storage.dart';
import 'app_init_result.dart';
import '../devices/device_id_provider.dart';

class AppInitializer {
  final SessionStorage sessionStorage;
  final DeviceIdProvider deviceIdProvider;

  AppInitializer({
    required this.sessionStorage,
    required this.deviceIdProvider,
  });

  Future<AppInitResult> initialize() async {
    final session = await sessionStorage.load();

    if (session != null) {
      return AppInitReady(session);
    }

    final deviceId = await deviceIdProvider.getOrCreate();
    return AppInitNeedLogin(deviceId);
  }
}