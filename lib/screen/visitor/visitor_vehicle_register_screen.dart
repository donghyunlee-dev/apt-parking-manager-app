import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../core/sessions/session_context.dart';
import 'services/visitor_vehicle_api.dart';
import '../../core/constants/colors.dart';

class VisitorVehicleRegisterScreen extends StatefulWidget {
  const VisitorVehicleRegisterScreen({super.key});

  @override
  State<VisitorVehicleRegisterScreen> createState() => _VisitorVehicleRegisterScreenState();
}

class _VisitorVehicleRegisterScreenState extends State<VisitorVehicleRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SessionContext _sessionContext;
  bool _sessionInitialized = false;

  final _vehicleNoPart1Controller = TextEditingController();
  final _vehicleNoPart2Controller = TextEditingController();
  final _vehicleNoPart3Controller = TextEditingController();
  final _vehicleNoPart1Focus = FocusNode();
  final _vehicleNoPart2Focus = FocusNode();
  final _vehicleNoPart3Focus = FocusNode();

  final _bdIdController = TextEditingController();
  final _bdUnitController = TextEditingController();

  final _phonePart2Controller = TextEditingController();
  final _phonePart3Controller = TextEditingController();
  final _phonePart3Focus = FocusNode();

  Timer? _hangulTimer;
  final _memoController = TextEditingController();

  DateTimeRange? _visitPeriod;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _fillVehicleNo(args);
      }
    });
  }

  void _fillVehicleNo(String vehicleNo) {
    final regex = RegExp(r'^(\d{2,3})([가-힣])(\d{4})$');
    final match = regex.firstMatch(vehicleNo);
    if (match != null) {
      _vehicleNoPart1Controller.text = match.group(1) ?? '';
      _vehicleNoPart2Controller.text = match.group(2) ?? '';
      _vehicleNoPart3Controller.text = match.group(3) ?? '';
    }
  }

  @override
  void dispose() {
    _vehicleNoPart1Controller.dispose();
    _vehicleNoPart2Controller.dispose();
    _vehicleNoPart3Controller.dispose();
    _vehicleNoPart1Focus.dispose();
    _vehicleNoPart2Focus.dispose();
    _vehicleNoPart3Focus.dispose();
    _bdIdController.dispose();
    _bdUnitController.dispose();
    _phonePart2Controller.dispose();
    _phonePart3Controller.dispose();
    _phonePart3Focus.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sessionInitialized) {
      _sessionContext = context.read<SessionContext>();
      _sessionInitialized = true;
    }
  }

  Future<void> _pickVisitPeriod() async {
    final period = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _visitPeriod,
    );
    if (period != null) {
      setState(() => _visitPeriod = period);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_visitPeriod == null) {
      _showError('방문 기간을 선택해주세요.');
      return;
    }

    setState(() => _loading = true);

    final vehicleNo = '${_vehicleNoPart1Controller.text}${_vehicleNoPart2Controller.text}${_vehicleNoPart3Controller.text}';
    final phone = '010-${_phonePart2Controller.text}-${_phonePart3Controller.text}';
    final String currentTime = DateFormat('HH:mm').format(DateTime.now());
     
    try {
      final response = await VisitorVehicleApi.register(
        vehicleNo: vehicleNo,
        bdId: _bdIdController.text.trim(),
        bdUnit: _bdUnitController.text.trim(),
        phone: phone,
        visitDate: DateFormat('yyyy-MM-dd').format(_visitPeriod!.start),
        visitTime: currentTime,
        visitCloseDate: DateFormat('yyyy-MM-dd').format(_visitPeriod!.end),
        memo: _memoController.text.trim(),
        sessionContext: _sessionContext,
      );

      if (!mounted) return;
      _showSuccess(response.message);
      _resetForm();
      _vehicleNoPart1Focus.requestFocus(); // Explicit focus after reset
    } catch (e) {
      _showError('차량 등록에 실패했습니다: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('방문 차량 등록'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('차량 번호'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _RoundedInput(
                        controller: _vehicleNoPart1Controller,
                        label: '앞자리',
                        focusNode: _vehicleNoPart1Focus,
                        keyboardType: TextInputType.number,
                        maxLength: 3,
                        textAlign: TextAlign.center,
                        onChanged: (v) {
                          if (v.length == 3) _vehicleNoPart2Focus.requestFocus();
                        },
                        validator: (v) => v == null || (v.length < 2 || v.length > 3) ? '2-3자리' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: _RoundedInput(
                        controller: _vehicleNoPart2Controller,
                        label: '한글',
                        focusNode: _vehicleNoPart2Focus,
                        maxLength: 2,
                        textAlign: TextAlign.center,
                        onChanged: (v) {
                          _hangulTimer?.cancel();
                          // 완성된 한글 1자일 때만 0.6초 후 포커스 이동
                          if (v.length == 1 && RegExp(r'^[가-힣]$').hasMatch(v)) {
                            _hangulTimer = Timer(const Duration(milliseconds: 600), () {
                              if (mounted && _vehicleNoPart2Controller.text == v) {
                                _vehicleNoPart3Focus.requestFocus();
                              }
                            });
                          }
                        },
                        validator: (v) => (v == null || !RegExp(r'^[가-힣]$').hasMatch(v)) ? '한글 1자' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: _RoundedInput(
                        controller: _vehicleNoPart3Controller,
                        label: '뒷자리',
                        focusNode: _vehicleNoPart3Focus,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (v) => v == null || v.length != 4 ? '4자리' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('동/호수'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RoundedInput(
                        controller: _bdIdController,
                        label: '동(숫자만)',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? '필수' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedInput(
                        controller: _bdUnitController,
                        label: '호(숫자만)',
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? '필수' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('연락처'),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(child: _RoundedInput(enabled: false, label: '010')),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedInput(
                        controller: _phonePart2Controller,
                        label: '중간',
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onChanged: (v) {
                          if (v.length == 4) _phonePart3Focus.requestFocus();
                        },
                        validator: (v) => v == null || v.length != 4 ? '4자리' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoundedInput(
                        controller: _phonePart3Controller,
                        label: '끝',
                        focusNode: _phonePart3Focus,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        validator: (v) => v == null || v.length != 4 ? '4자리' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('방문 기간'),
                const SizedBox(height: 12),
                _buildDateRangePicker(),
                const SizedBox(height: 24),
                _buildSectionTitle('메모'),
                const SizedBox(height: 12),
                _RoundedInput(
                  controller: _memoController,
                  label: '관리자 확인용',
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('차량 등록하기'),
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

  Widget _buildDateRangePicker() {
    final start = _visitPeriod?.start;
    final end = _visitPeriod?.end;
    String text;
    if (start == null || end == null) {
      text = '방문 기간을 선택하세요';
    } else {
      text = '${DateFormat('yyyy.MM.dd').format(start)} - ${DateFormat('yyyy.MM.dd').format(end)}';
    }

    return InkWell(
      onTap: _pickVisitPeriod,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _visitPeriod == null ? Colors.grey.shade600 : Colors.black,
              ),
            ),
            const Icon(Icons.calendar_today, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _vehicleNoPart1Controller.clear();
    _vehicleNoPart2Controller.clear();
    _vehicleNoPart3Controller.clear();
    _bdIdController.clear();
    _bdUnitController.clear();
    _phonePart2Controller.clear();
    _phonePart3Controller.clear();
    _memoController.clear();
    setState(() => _visitPeriod = null);
    if (mounted) {
      FocusScope.of(context).unfocus();
    }
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
        errorStyle: const TextStyle(fontSize: 10),
      ),
      validator: validator,
    );
  }
}