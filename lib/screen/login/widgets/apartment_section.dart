import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../models/apartment.dart';

class ApartmentSection extends StatelessWidget {
  final Apartment? apartment;
  final String? currentAddress;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ApartmentSection({
    super.key,
    required this.apartment,
    required this.currentAddress,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (apartment == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentAddress != null) ...[
              const Icon(Icons.location_on, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                '현재 위치: $currentAddress',
                style: const TextStyle(color: AppColors.greyText, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            const Icon(Icons.location_off_outlined,
                size: 64, color: AppColors.greyText),
            const SizedBox(height: 16),
            const Text(
              '이 주변에 등록된 아파트가 없어요',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              '직접 아파트를 등록하거나 위치를 다시 확인해보세요.',
              style: TextStyle(color: AppColors.greyText),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('다시 검색하기'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.apartment_rounded, size: 40, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          apartment!.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          apartment!.address,
          style: const TextStyle(color: AppColors.greyText, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

