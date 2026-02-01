import 'package:flutter/material.dart';

class FinKeypad extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onNumberPressed;
  final VoidCallback onDeletePressed;

  const FinKeypad({
    super.key,
    required this.enabled,
    required this.onNumberPressed,
    required this.onDeletePressed,
  });



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _KeypadColors.from(theme);

    return AbsorbPointer(
      absorbing: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.25,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            // 빈 셀 (0 왼쪽)
            if (index == 9) {
              return _KeyCell(
                colors: colors,
                child: const SizedBox.shrink(),
              );
            }

            // 0
            if (index == 10) {
              return _KeyCell(
                colors: colors,
                onTap: () => onNumberPressed('0'),
                child: Text(
                  '0',
                  style: _numberStyle,
                ),
              );
            }

            // 삭제
            if (index == 11) {
              return _KeyCell(
                colors: colors,
                onTap: onDeletePressed,
                child: Icon(
                  Icons.backspace_outlined,
                  color: colors.icon,
                ),
              );
            }

            // 1~9
            final number = index + 1;
            return _KeyCell(
              colors: colors,
              onTap: () => onNumberPressed(number.toString()),
              child: Text(
                number.toString(),
                style: _numberStyle,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KeyCell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final _KeypadColors colors;

  const _KeyCell({
    required this.child,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.background,
          border: Border.all(
            color: colors.border,
            width: 0.8,
          ),
        ),
        child: child,
      ),
    );
  }
}

class _KeypadColors {
  final Color background;
  final Color border;
  final Color icon;

  _KeypadColors({
    required this.background,
    required this.border,
    required this.icon,
  });

  factory _KeypadColors.from(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return _KeypadColors(
      background: isDark
          ? const Color(0xFF1E1E1E)
          : const Color(0xFFF4F5F7),
      border: isDark
          ? const Color(0xFF2C2C2C)
          : const Color(0xFFE0E0E0),
      icon: isDark
          ? Colors.white70
          : Colors.black54,
    );
  }
}
  
const TextStyle _numberStyle = TextStyle(
  
  fontSize: 26,
  fontWeight: FontWeight.w500,
);
