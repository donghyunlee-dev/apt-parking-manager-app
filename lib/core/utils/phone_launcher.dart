import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class PhoneLauncher {
  /// 전화번호를 정제하고 전화를 겁니다.
  static Future<void> makeCall(String phoneNumber) async {
    // 숫자가 아닌 문자 제거
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanNumber.isEmpty) {
      debugPrint('PhoneLauncher: Invalid phone number');
      return;
    }

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanNumber,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        debugPrint('PhoneLauncher: Could not launch $launchUri');
      }
    } catch (e) {
      debugPrint('PhoneLauncher Error: $e');
    }
  }
}
