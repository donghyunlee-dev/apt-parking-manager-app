import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _keyAutoScan = 'auto_scan';
  static const String _keyVoiceEnabled = 'voice_enabled';

  bool _isAutoScanEnabled = true;
  bool _isVoiceEnabled = true;

  bool get isAutoScanEnabled => _isAutoScanEnabled;
  bool get isVoiceEnabled => _isVoiceEnabled;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isAutoScanEnabled = prefs.getBool(_keyAutoScan) ?? true;
    _isVoiceEnabled = prefs.getBool(_keyVoiceEnabled) ?? true;
    notifyListeners();
  }

  Future<void> setAutoScan(bool value) async {
    _isAutoScanEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAutoScan, value);
    notifyListeners();
  }

  Future<void> setVoiceEnabled(bool value) async {
    _isVoiceEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyVoiceEnabled, value);
    notifyListeners();
  }
}
