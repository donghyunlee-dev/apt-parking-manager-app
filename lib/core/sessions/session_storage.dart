import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'session.dart';

class SessionStorage {
  static const _deviceIdKey = 'device_id';
  static const _aptCodeKey = 'apt_code';
  static const _aptNameKey = 'apt_name';
  static const _bouncerCodeKey = 'bouncer_code';
  static const _bouncerNameKey = 'bouncer_name';
  static const _createdAtKey = 'created_at';

  final FlutterSecureStorage _storage;
  SessionStorage(this._storage);

  Future<String?> readDeviceId() {
    return _storage.read(key: _deviceIdKey);
  }

  Future<void> saveAptCode(String aptCode) async {
    await _storage.write(key: _aptCodeKey, value: aptCode);
  }

  Future<void> saveBouncerCode(String bouncerCode) async {
    await _storage.write(key: _bouncerCodeKey, value: bouncerCode);
  }

  Future<void> save(Session session) async {
    await _storage.write(key: _deviceIdKey, value: session.deviceId);
    await _storage.write(key: _aptCodeKey, value: session.aptCode);
    await _storage.write(key: _aptNameKey, value: session.aptName);
    await _storage.write(key: _bouncerCodeKey, value: session.bouncerCode);
    await _storage.write(key: _bouncerNameKey, value: session.bouncerName);
    await _storage.write(key: _createdAtKey, value: session.createdAt.toIso8601String());
  }

  Future<Session?> load() async {
    final deviceId = await _storage.read(key: _deviceIdKey);
    final aptCode = await _storage.read(key: _aptCodeKey);
    final aptName = await _storage.read(key: _aptNameKey);
    final bouncerCode = await _storage.read(key: _bouncerCodeKey);
    final bouncerName = await _storage.read(key: _bouncerNameKey);
    final createdAtStr = await _storage.read(key: _createdAtKey);

    if (deviceId == null || aptCode == null || aptName == null || bouncerCode == null || bouncerName == null || createdAtStr == null) {
      return null;
    }

    return Session(
      deviceId: deviceId,
      aptCode: aptCode,
      aptName: aptName,
      bouncerCode: bouncerCode,
      bouncerName: bouncerName,
      createdAt: DateTime.parse(createdAtStr),
    );
  }

  Future<void> clear() async {
    await _storage.delete(key: _aptCodeKey);
    await _storage.delete(key: _aptNameKey);
    await _storage.delete(key: _bouncerCodeKey);
    await _storage.delete(key: _bouncerNameKey);
    await _storage.delete(key: _createdAtKey);
  }
}