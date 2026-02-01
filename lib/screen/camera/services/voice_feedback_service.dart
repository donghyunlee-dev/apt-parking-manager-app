import 'package:flutter_tts/flutter_tts.dart';

class VoiceFeedbackService {
  static final VoiceFeedbackService _instance =
      VoiceFeedbackService._internal();

  factory VoiceFeedbackService() => _instance;

  VoiceFeedbackService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
  }

  Future<void> speak(String message) async {
    await _tts.stop();
    await _tts.speak(message);
  }
}
