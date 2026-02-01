import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';
import '../core/sessions/app_init_result.dart';


class AppInitScreen extends StatefulWidget {
  final AppInitResult result;
  const AppInitScreen({
    super.key,
    required this.result,
  });

  @override
  State<AppInitScreen> createState() => _AppInitScreenState();
}

class _AppInitScreenState extends State<AppInitScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  void _route() {
    Future.delayed(const Duration(seconds: 1), () {

      if (!mounted) return;

      switch (widget.result) {
      case AppInitReady():
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          );

      case AppInitNeedLogin():
          Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          );

      case AppInitError():
          _showErrorAndExit(context, '초기화 실패');
      }
    });
  }
 
  void _showErrorAndExit(BuildContext context, String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
        title: const Text('초기화 실패'),
        content: Text(message),
        actions: [
            TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('앱 종료'),
            ),
        ],
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}


