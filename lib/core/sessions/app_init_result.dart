import 'session.dart';

sealed class AppInitResult {
  const AppInitResult();
}

final class AppInitReady extends AppInitResult {
  final Session session;
  const AppInitReady(this.session);
}

final class AppInitNeedLogin extends AppInitResult {
  final String deviceId;
  const AppInitNeedLogin(this.deviceId);
}

final class AppInitError extends AppInitResult {
  final String message;
  const AppInitError(this.message);
}
