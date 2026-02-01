import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class DeviceIdProvider {
  final FlutterSecureStorage _storage;

  DeviceIdProvider(this._storage);
  
  static const _key = 'device_id';
  
  Future<String> getOrCreate() async {
    final stored = await _storage.read(key: _key);
    
    if (stored != null) return stored;

    final newId = _generateUuid();
    await _storage.write(key: _key, value: newId);
    return newId;
  }

  String _generateUuid() {
    return const Uuid().v4();
  }
}
