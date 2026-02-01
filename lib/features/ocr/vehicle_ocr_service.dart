import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart';

class VehicleOcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.korean,);

  Future<String?> recognizePlate(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _recognizer.processImage(inputImage);
    // 디버깅용 아래 코드는 나중에 삭제
    for (final block in recognizedText.blocks) {
      for (final line in block.lines) {
        debugPrint('➡️ LINE: ${line.text}');
      }
    } 
    return _extractPlate(recognizedText.text);
  }

  String? _extractPlate(String rawText) {
    final regex = RegExp(r'\d{2,3}[가-힣]\d{4}');
    final match = regex.firstMatch(rawText.replaceAll(' ', ''));
    return match?.group(0);
  }

  void dispose() {
    _recognizer.close();
  }
}
