import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/sessions/session_context.dart';
import '../../core/utils/phone_launcher.dart';
import '../../models/searched_vehicle.dart';
import '../../core/constants/colors.dart';
import 'services/search_vehicle_api.dart';

class SearchVehicleScreen extends StatefulWidget {
  const SearchVehicleScreen({super.key});

  @override
  State<SearchVehicleScreen> createState() => _SearchVehicleScreenState();
}

class _SearchVehicleScreenState extends State<SearchVehicleScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchedVehicle? _searchResult;
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
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchResult = null;
    });

    try {
      final response = await SearchVehicleApi.search(
        vehicleNo: trimmedQuery,
        sessionContext: _sessionContext,
      );

      if (mounted) {
        setState(() {
          _searchResult = response.data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('차량 검색에 실패했습니다: ${e.toString()}'), backgroundColor: AppColors.error),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('차량 검색'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.greyText),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '차량번호를 입력하세요',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
                onSubmitted: _performSearch,
                textInputAction: TextInputAction.search,
              ),
            ),
            if (_searchController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: AppColors.greyText),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _hasSearched = false;
                    _searchResult = null;
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.primary),
              onPressed: () => _performSearch(_searchController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_hasSearched) {
      return _buildEmptyState('차량 번호를 입력하여\n검색을 시작하세요.', Icons.search_rounded);
    }

    if (_searchResult == null || _searchResult!.vehicleNo == null) {
        return _buildEmptyState('검색된 차량 정보가 없습니다.\n차량 번호를 다시 확인해주세요.', Icons.info_outline_rounded);
    }

    return _buildSearchResultCard(_searchResult!);
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 80, color: AppColors.greyText.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.greyText, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(SearchedVehicle vehicle) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vehicle.vehicleNo ?? '알 수 없음',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                _buildStatusTag(vehicle.type),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.apartment_rounded, '단지 정보', '${vehicle.bdId ?? '-'}동 ${vehicle.bdUnit ?? '-'}호'),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.phone_rounded, '연락처', vehicle.phone ?? '비공개', isPhone: true),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.notes_rounded, '메모', vehicle.memo ?? '메모 없음'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTag(String? status) {
    Color color;
    String text;
    switch (status) {
      case 'RESIDENT':
        color = AppColors.primary;
        text = '입주 차량';
        break;
      case 'VISITOR':
        color = const Color(0xFF6DCC5D);
        text = '방문 차량';
        break;
      case 'ILLEGAL':
        color = AppColors.error;
        text = '불법/미등록';
        break;
      default:
        color = AppColors.greyText;
        text = '데이터 없음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isPhone = false}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.greyText, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.greyText, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.black)),
            ],
          ),
        ),
        if (isPhone && value != '비공개' && value.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
            onPressed: () => PhoneLauncher.makeCall(value),
            tooltip: '전화 걸기',
          ),
      ],
    );
  }
}