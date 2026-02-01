import 'package:flutter/foundation.dart';
import 'session.dart';

class SessionContext extends ChangeNotifier {
  Session? _session;

  Session? get session => _session;
  bool get isAuthenticated => _session != null;

  void setSession(Session session) {
    _session = session;
    notifyListeners();
  }

  void clear() {
    _session = null;
    notifyListeners();
  }

  /// 🔑 공통 헤더 변환
  Map<String, String> get headers {
    if (_session == null) return {};

    return {
      'X-Device-Id': _session!.deviceId,
      'X-Apt-Code': _session!.aptCode,
      'X-Bouncer-Code': _session!.bouncerCode,
      'X-App-Version': "0.0.1",
    };
  }

  @override
  String toString() {
    return 'SessionContext(headers=$headers)';
  }
}
