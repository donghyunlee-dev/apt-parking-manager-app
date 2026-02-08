import '../../../core/sessions/session_storage.dart';
import '../../../core/sessions/session_context.dart';
import '../../../core/sessions/session.dart';
import '../../../models/bouncer.dart';
import 'fin_api.dart';

class LoginService {
  final SessionStorage sessionStorage;
  final SessionContext sessionContext;
  final FinApi finApi;

  LoginService({
    required this.sessionStorage,
    required this.sessionContext,
    required this.finApi,
  });

  Future<Bouncer?> login({
    required String aptCode,
    required String aptName,
    required String finCode,
    required String address,
  }) async {
    final deviceId = await sessionStorage.readDeviceId();

    if (deviceId == null) {
      throw Exception('DeviceId not initialized');
    }

    final Bouncer? bouncer = await finApi.verifyFin(
        aptCode: aptCode,
        finCode: finCode,
        deviceId: deviceId,
        location: address,
      );

    if (bouncer == null || bouncer.code.isEmpty) {
      throw Exception('FIN verification failed');
    }

    final session = Session(
      deviceId: deviceId,
      aptCode: aptCode,
      aptName: aptName,
      bouncerCode: bouncer.code,
      bouncerName: bouncer.name,
      createdAt: DateTime.now(),
    );
    await sessionStorage.save(session);
    sessionContext.setSession(session);

    return bouncer;
  }
}
