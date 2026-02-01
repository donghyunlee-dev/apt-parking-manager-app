import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../core/flatform/location_channel.dart';
import '../../core/sessions/session_context.dart';
import '../../models/apartment.dart';
import '../../models/bouncer.dart';
import 'services/apartment_api.dart';
import 'services/login_service.dart';
import 'widgets/apartment_section.dart';
import 'widgets/fin_input_section.dart';
import 'widgets/fin_keypad.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Apartment? apartment;

  bool _isLoading = false;
  bool _isBlocked = false;
  bool _isSubmitting = false;
  bool _showFinInput = false;

  int _failCount = 0;

  static const int finLength = 6;
  String _fin = '';
  late final LoginService _loginService;

  @override
  void initState() {
    super.initState();
    _loadApartment();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loginService = context.read<LoginService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// 중앙 콘텐츠 영역
            Expanded(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                alignment:
                    _showFinInput ? Alignment.topCenter : Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildCenterContent(),
                ),
              ),
            ),

            /// 하단 키패드 영역
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showFinInput ? _buildBottomArea() : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  /// -----------------------
  /// 중앙 콘텐츠
  /// -----------------------
  Widget _buildCenterContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ApartmentSection(
          apartment: apartment,
          isLoading: _isLoading,
          onRefresh: _loadApartment,
        ),

        const SizedBox(height: 20),

        if (_showFinInput)
          FinInputSection(
            fin: _fin,
            length: finLength,
          ),

        const SizedBox(height: 32),

        if (!_showFinInput) _buildActionButton(),
      ],
    );
  }

  /// -----------------------
  /// 버튼 분기
  /// -----------------------
  Widget _buildActionButton() {
    // 아파트 정보 있음
    if (apartment != null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _showFinInput = true;
            });
          },
          child: const Text(
            '주차 관리 시작',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    // 아파트 정보 없음
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: 아파트 등록 화면 이동
        },
        child: const Text(
          '아파트 등록',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  /// -----------------------
  /// 하단 영역 (타이틀 + 키패드)
  /// -----------------------
  Widget _buildBottomArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FinTitleBar(
          onClose: () {
            setState(() {
              _fin = '';
              _showFinInput = false;
            });
          },
        ),

        Stack(
          children: [
            FinKeypad(
              enabled: !_isSubmitting && !_isBlocked,
              onNumberPressed: _onNumberPressed,
              onDeletePressed: _onDeletePressed,
            ),

            if (_isSubmitting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.05),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),

        if (_isBlocked)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(
              '시도 횟수를 초과했습니다.\n잠시 후 다시 시도하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  /// -----------------------
  /// 위치 기반 아파트 조회
  /// -----------------------
  Future<void> _loadApartment() async {
    setState(() => _isLoading = true);

    try {
      final address = await LocationChannel.getCurrentAddress();

      if (address == null || address.isEmpty) return;

      final result = await ApartmentApi.findByAddress(address);

      setState(() {
        apartment = result;
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION') {
        final status = await Permission.locationWhenInUse.request();
        if (status.isGranted) {

          final address = await LocationChannel.getCurrentAddress();

          if (address == null || address.isEmpty) return;

          final result = await ApartmentApi.findByAddress(address);
          setState(() {
            apartment = result;
          });
        }
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// -----------------------
  /// FIN 입력 처리
  /// -----------------------
  void _onNumberPressed(String value) {
    if (_isBlocked || _fin.length >= finLength) return;

    setState(() {
      _fin += value;
    });

    if (_fin.length == finLength) {
      _submitFinCode();
    }
  }

  void _onDeletePressed() {
    if (_fin.isEmpty) return;

    setState(() {
      _fin = _fin.substring(0, _fin.length - 1);
    });
  }

  Future<void> _submitFinCode() async {
 
    setState(() => _isSubmitting = true);

    try {
      final bouncer = _loginService.login(aptCode: apartment!.code, aptName: apartment!.name, finCode: _fin, address: apartment!.address);
    
      if (bouncer != true) {
           
        Navigator.pushReplacementNamed(
          context,
          '/home',
        );
        return;
      }

      _handleFailed();
    } catch (_) {
      _handleFailed();
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _handleFailed() {
    setState(() {
      _failCount++;
      if (_failCount >= 5) {
        _isBlocked = true;
      }
    });
  }
}

/// -----------------------
/// FIN 타이틀 바
/// -----------------------
class _FinTitleBar extends StatelessWidget {
  final VoidCallback onClose;

  const _FinTitleBar({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          const Spacer(),
          const Text(
            '핀번호를 입력하세요',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}
