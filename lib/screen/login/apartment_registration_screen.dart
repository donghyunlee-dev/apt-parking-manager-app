import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/devices/device_id_provider.dart';
import 'services/apartment_registration_api.dart';

class ApartmentRegistrationScreen extends StatefulWidget {
  final String? initialAddress;

  const ApartmentRegistrationScreen({super.key, this.initialAddress});

  @override
  State<ApartmentRegistrationScreen> createState() => _ApartmentRegistrationScreenState();
}

class _ApartmentRegistrationScreenState extends State<ApartmentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _buildingCountController = TextEditingController();
  final _residentCountController = TextEditingController();
  final _finCodeController = TextEditingController();
  final _finCodeConfirmController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressController.text = widget.initialAddress ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _buildingCountController.dispose();
    _residentCountController.dispose();
    _finCodeController.dispose();
    _finCodeConfirmController.dispose();
    super.dispose();
  }

  String? _validateFinCode(String? value) {
    if (value == null || value.isEmpty) {
      return '필수 입력';
    }
    if (value.length != 6) {
      return '6자리';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '숫자만';
    }
    return null;
  }

  String? _validateFinCodeConfirm(String? value) {
    final error = _validateFinCode(value);
    if (error != null) return error;
    
    if (value != _finCodeController.text) {
      return '불일치';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Device ID 생성 및 획득
      final deviceId = await context.read<DeviceIdProvider>().getOrCreate();

      final response = await ApartmentRegistrationApi.register(
        aptName: _nameController.text.trim(),
        address: _addressController.text.trim(),
        building: int.parse(_buildingCountController.text.trim()),
        resident: int.parse(_residentCountController.text.trim()),
        finNo: _finCodeController.text.trim(),
        deviceId: deviceId,
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아파트가 성공적으로 등록되었습니다.'), backgroundColor: AppColors.success),
      );

      // 등록 성공 후 로그인 화면으로 이동
      Navigator.pushReplacementNamed(context, '/login');
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('등록 중 오류가 발생했습니다: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('아파트 등록'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('아파트 정보'),
                const SizedBox(height: 12),
                
                _RoundedInput(
                  controller: _nameController,
                  label: '아파트 이름',
                  validator: (v) => v == null || v.isEmpty ? '필수 입력' : null,
                ),
                const SizedBox(height: 12),
                
                _RoundedInput(
                  controller: _addressController,
                  label: '주소',
                  validator: (v) => v == null || v.isEmpty ? '필수 입력' : null,
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('단지 정보'),
                const SizedBox(height: 12),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RoundedInput(
                        controller: _buildingCountController,
                        label: '동 수',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? '필수' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedInput(
                        controller: _residentCountController,
                        label: '세대 수',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? '필수' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle('로그인 FIN 번호 설정'),
                const SizedBox(height: 8),
                const Text(
                  '로그인 시 사용할 6자리 숫자 FIN 번호를 설정해주세요.',
                  style: TextStyle(fontSize: 13, color: AppColors.greyText),
                ),
                const SizedBox(height: 12),
                
                _RoundedInput(
                  controller: _finCodeController,
                  label: 'FIN 번호(6자리 숫자)',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  validator: _validateFinCode,
                ),
                const SizedBox(height: 12),
                
                _RoundedInput(
                  controller: _finCodeConfirmController,
                  label: 'FIN 번호 확인',
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  obscureText: true,
                  validator: _validateFinCodeConfirm,
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('아파트 등록하기'),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.greyText),
    );
  }
}

class _RoundedInput extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final TextAlign textAlign;
  final bool obscureText;

  const _RoundedInput({
    this.controller,
    required this.label,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.onChanged,
    this.textAlign = TextAlign.start,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      textAlign: textAlign,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade200,
        counterText: '',
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        errorStyle: const TextStyle(fontSize: 12), // 에러 메시지 폰트 사이즈 조정
      ),
      validator: validator,
    );
  }
}
