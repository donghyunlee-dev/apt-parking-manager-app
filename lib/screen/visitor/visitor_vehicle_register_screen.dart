import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/sessions/session_context.dart';

class VisitorVehicleRegisterScreen extends StatefulWidget {
  const VisitorVehicleRegisterScreen({super.key});

  @override
  State<VisitorVehicleRegisterScreen> createState() =>
      _VisitorVehicleRegisterScreenState();
}

class _VisitorVehicleRegisterScreenState
    extends State<VisitorVehicleRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SessionContext _sessionContext;
  bool _sessionInitialized = false;

  // Vehicle Number Controllers
  final _vehicleNoPart1Controller = TextEditingController();
  final _vehicleNoPart2Controller = TextEditingController();
  final _vehicleNoPart3Controller = TextEditingController();
  final _vehicleNoPart2Focus = FocusNode();
  final _vehicleNoPart3Focus = FocusNode();

  // Building/Unit Controllers
  final _bdIdController = TextEditingController();
  final _bdUnitController = TextEditingController();

  // Phone Number Controllers
  final _phonePart2Controller = TextEditingController();
  final _phonePart3Controller = TextEditingController();
  final _phonePart3Focus = FocusNode();

  final _memoController = TextEditingController();

  DateTimeRange? _visitPeriod;
  bool _loading = false;

  @override
  void dispose() {
    _vehicleNoPart1Controller.dispose();
    _vehicleNoPart2Controller.dispose();
    _vehicleNoPart3Controller.dispose();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_sessionInitialized) {
      _sessionContext = context.read<SessionContext>();
      _sessionInitialized = true;
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_visitPeriod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방문 기간을 선택해주세요.')),
      );
      return;
    }

    final vehicleNo =
        '${_vehicleNoPart1Controller.text}${_vehicleNoPart2Controller.text}${_vehicleNoPart3Controller.text}';
    final phone =
        '010-${_phonePart2Controller.text}-${_phonePart3Controller.text}';

    // API 연동은 추후 추가
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('방문차량 등록: $vehicleNo, $phone')),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '방문차량 등록',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '방문차량 정보를 입력해주세요',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _RoundedInput(
                              controller: _vehicleNoPart1Controller,
                              label: '차량 번호',
                              keyboardType: TextInputType.number,
                              maxLength: 3,
                              textAlign: TextAlign.center,
                              onChanged: (v) {
                                if (v.length == 3) {
                                  _vehicleNoPart2Focus.requestFocus();
                                }
                              },
                              validator: (v) => v == null ||
                                      (v.length < 2 || v.length > 3)
                                  ? '2-3자리'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: _RoundedInput(
                              controller: _vehicleNoPart2Controller,
                              label: ' ',
                              focusNode: _vehicleNoPart2Focus,
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              onChanged: (v) {
                                if (v.length == 1) {
                                  _vehicleNoPart3Focus.requestFocus();
                                }
                              },
                              validator: (v) {
                                if (v == null || v.length != 1) return '한 글자';
                                if (!RegExp(r'^[가-힣]+$').hasMatch(v)) {
                                  return '한글';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: _RoundedInput(
                              controller: _vehicleNoPart3Controller,
                              label: ' ',
                              focusNode: _vehicleNoPart3Focus,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              validator: (v) =>
                                  v == null || v.length != 4 ? '4자리' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _RoundedInput(
                              controller: _bdIdController,
                              label: '동',
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v == null || v.isEmpty ? '동 입력' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoundedInput(
                              controller: _bdUnitController,
                              label: '호',
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v == null || v.isEmpty ? '호 입력' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: _RoundedInput(
                              enabled: false,
                              label: '010',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoundedInput(
                              controller: _phonePart2Controller,
                              label: '',
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              onChanged: (v) {
                                if (v.length == 4) {
                                  _phonePart3Focus.requestFocus();
                                }
                              },
                              validator: (v) =>
                                  v == null || v.length != 4 ? '4자리' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoundedInput(
                              controller: _phonePart3Controller,
                              label: '',
                              focusNode: _phonePart3Focus,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              validator: (v) =>
                                  v == null || v.length != 4 ? '4자리' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildDateRangePicker(),
                      const SizedBox(height: 24),
                      _RoundedInput(
                        controller: _memoController,
                        label: '메모',
                        maxLines: 3,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 0),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('등록',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
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
      text =
          '${DateFormat('yyyy.MM.dd').format(start)} - ${DateFormat('yyyy.MM.dd').format(end)}';
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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