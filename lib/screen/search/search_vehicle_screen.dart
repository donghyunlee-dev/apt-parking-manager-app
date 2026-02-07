import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/sessions/session_context.dart';
import '../../models/searched_vehicle.dart';
import 'services/search_vehicle_api.dart';

class SearchVehicleScreen extends StatefulWidget {
  const SearchVehicleScreen({super.key});

  @override
  State<SearchVehicleScreen> createState() => _SearchVehicleScreenState();
}

class _SearchVehicleScreenState extends State<SearchVehicleScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchedVehicle> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  
  late final SessionContext _sessionContext;
  bool _sessionInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_sessionInitialized) {
      _sessionContext = context.read<SessionContext>();
      _sessionInitialized = true;
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResults = []; // Clear previous results
    });

    try {
      final response = await SearchVehicleApi.search(
        vehicleNo: query,
        sessionContext: _sessionContext,
      );

      if (mounted) {
        setState(() {
          _searchResults = response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차량 검색에 실패했습니다: ${e.toString()}')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    '차량 검색',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '차량 번호를 입력하여 검색하세요.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _RoundedInput(
                          controller: _searchController,
                          label: '차량번호 입력',
                          keyboardType: TextInputType.text,
                          onChanged: (value) {
                            if (value.isEmpty && _hasSearched) {
                              _performSearch('');
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      SizedBox(
                        height: 56, // Match height of _RoundedInput
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : () => _performSearch(_searchController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12), // Match input border radius
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white))
                              : const Text('검색', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_hasSearched && _searchResults.isEmpty) {
      return const Center(child: Text('검색 결과가 없습니다.'));
    } else if (_searchResults.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final vehicle = _searchResults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleNo,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '타입: ${_getVehicleType(vehicle.type)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  if (vehicle.bdId != null && vehicle.bdUnit != null)
                    Text(
                      '정보: ${vehicle.bdId}동 ${vehicle.bdUnit}호',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  if (vehicle.memo?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 4),
                    Text(
                      '메모: ${vehicle.memo}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    } else {
      return const Center(child: Text('차량 번호를 입력하여 검색해주세요.'));
    }
  }

  String _getVehicleType(String type) {
    switch (type) {
      case 'resident':
        return '입주민';
      case 'visitor':
        return '방문객';
      case 'unregistered':
        return '미등록';
      default:
        return '알 수 없음';
    }
  }
}

// Reusable RoundedInput widget, adapted from resident_vehicle_register_screen.dart
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
          borderSide:
              BorderSide(color: theme.colorScheme.primary, width: 2),
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