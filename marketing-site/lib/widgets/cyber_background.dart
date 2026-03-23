import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CyberBackground extends StatelessWidget {
  const CyberBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF070B14), AppColors.background, Color(0xFF0B1424)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),
        ),
        Positioned(
          top: -180,
          right: -140,
          child: _GlowOrb(
            size: 420,
            color: AppColors.accent.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -120,
          left: -140,
          child: _GlowOrb(
            size: 360,
            color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 120, spreadRadius: 30),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 42.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final circuitPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.22)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final random = Random(7);
    for (var i = 0; i < 18; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final midX =
          (startX + random.nextDouble() * 220).clamp(0, size.width).toDouble();
      final endY =
          (startY + random.nextDouble() * 160).clamp(0, size.height).toDouble();

      final path = Path()
        ..moveTo(startX, startY)
        ..lineTo(midX, startY)
        ..lineTo(midX, endY);

      canvas.drawPath(path, circuitPaint);
      canvas.drawCircle(
        Offset(midX, endY),
        2.6,
        Paint()..color = AppColors.accent.withValues(alpha: 0.28),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
