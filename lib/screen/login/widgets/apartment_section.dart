import 'package:flutter/material.dart';
import '../../../models/apartment.dart';

class ApartmentSection extends StatelessWidget {
  final Apartment? apartment;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ApartmentSection({
    required this.apartment,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // 로딩 중
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 검색 실패
    if (apartment == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '아파트 정보를 찾을 수 없습니다.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRefresh,
              child: const Text('위치 다시 검색'),
            ),
          ],
        ),
      );
    }

    // 검색 성공
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          apartment!.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Icon(Icons.location_on, size: 40),
        const SizedBox(height: 8),
        Text(
          apartment!.address,
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

