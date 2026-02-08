import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class FinInputSection extends StatelessWidget {
  final String fin;
  final int length;

  const FinInputSection({
    super.key,
    required this.fin,
    this.length = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final filled = index < fin.length;

        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
