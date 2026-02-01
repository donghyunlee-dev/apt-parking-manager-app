import 'package:flutter/material.dart';

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
          width: 32,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: filled ? Colors.black : Colors.grey,
              ),
            ),
          ),
          child: Center(
            child: filled
                ? const Icon(Icons.circle, size: 10)
                : const SizedBox.shrink(),
          ),
        );
      }),
    );
  }
}
