import 'package:flutter/material.dart';

class PlateGuideOverlay extends StatelessWidget {
  const PlateGuideOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 가이드 프레임
          CustomPaint(
            size: const Size(320, 160),
            painter: PlateFramePainter(),
          ),
          const SizedBox(height: 20),

          // 안내 텍스트
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.center_focus_strong,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  '번호판을 프레임 안에 맞춰주세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlateFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 배경 어둡게
    final darkPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    
    // 구멍 뚫린 효과
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
      Rect.fromLTWH(-1000, -1000, 3000, 3000),
      darkPaint,
    );
    canvas.drawRRect(rrect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // 메인 프레임
    final framePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(rrect, framePaint);

    // 모서리 강조선
    final cornerLength = 40.0;
    final cornerPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    // 좌상단
    canvas.drawLine(
      const Offset(16, 16),
      Offset(16 + cornerLength, 16),
      cornerPaint,
    );
    canvas.drawLine(
      const Offset(16, 16),
      Offset(16, 16 + cornerLength),
      cornerPaint,
    );

    // 우상단
    canvas.drawLine(
      Offset(size.width - 16, 16),
      Offset(size.width - 16 - cornerLength, 16),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 16, 16),
      Offset(size.width - 16, 16 + cornerLength),
      cornerPaint,
    );

    // 좌하단
    canvas.drawLine(
      Offset(16, size.height - 16),
      Offset(16 + cornerLength, size.height - 16),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(16, size.height - 16),
      Offset(16, size.height - 16 - cornerLength),
      cornerPaint,
    );

    // 우하단
    canvas.drawLine(
      Offset(size.width - 16, size.height - 16),
      Offset(size.width - 16 - cornerLength, size.height - 16),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 16, size.height - 16),
      Offset(size.width - 16, size.height - 16 - cornerLength),
      cornerPaint,
    );

    // 중앙 크로스헤어
    final centerPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;
    
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    canvas.drawLine(
      Offset(centerX - 20, centerY),
      Offset(centerX + 20, centerY),
      centerPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 20),
      Offset(centerX, centerY + 20),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}