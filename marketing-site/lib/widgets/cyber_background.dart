import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_theme.dart';

const double _kGridSpacing = 42.0;

/// Full-viewport cyber aesthetic: gradient, drifting grid, circuit traces, glow orbs.
/// Uses elapsed time (not a looping 0–1 controller) so motion stays slow and continuous.
class CyberBackground extends StatefulWidget {
  const CyberBackground({super.key});

  @override
  State<CyberBackground> createState() => _CyberBackgroundState();
}

class _CyberBackgroundState extends State<CyberBackground>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<Duration> _elapsed = ValueNotifier(Duration.zero);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((Duration dt) {
      _elapsed.value += dt;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _elapsed,
      builder: (context, child) {
        final sec = _elapsed.value.inMicroseconds / 1e6;

        // Slow constant drift (pixels / second) — modulo spacing = seamless forever
        const vx = 1.15;
        const vy = 0.72;
        final gridOffsetX = (sec * vx) % _kGridSpacing;
        final gridOffsetY = (sec * vy) % _kGridSpacing;

        // Gradient axis rotates very slowly (constant angular speed)
        const gradientRadPerSec = 0.045;
        final angle = sec * gradientRadPerSec;
        const gradAmp = 0.1;
        final gx = gradAmp * cos(angle);
        final gy = gradAmp * sin(angle);

        // Circuit layer: slow drift + gentle brightness wave
        const circuitVx = 0.55;
        const circuitVy = 0.38;
        final circuitShiftX = (sec * circuitVx) % _kGridSpacing;
        final circuitShiftY = (sec * circuitVy) % _kGridSpacing;
        final circuitPulse = 0.78 + 0.22 * sin(sec * 0.38);

        // Orbs: slow Lissajous-style drift (never stops)
        const orbRad = 0.11;
        final orbDriftX = 28 * sin(sec * orbRad * 0.85);
        final orbDriftY = 22 * cos(sec * orbRad * 0.65);
        final orbBreath = 0.88 + 0.12 * sin(sec * 0.22);

        return Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFF070B14),
                      AppColors.background,
                      Color(0xFF0B1424),
                    ],
                    begin: Alignment(-1 + gx, -1 + gy),
                    end: Alignment(1 - gx, 1 - gy),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _GridPainter(
                    gridOffsetX: gridOffsetX,
                    gridOffsetY: gridOffsetY,
                    circuitShiftX: circuitShiftX,
                    circuitShiftY: circuitShiftY,
                    circuitPulse: circuitPulse,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -180 + orbDriftY * 0.4,
              right: -140 + orbDriftX * 0.3,
              child: IgnorePointer(
                child: Opacity(
                  opacity: orbBreath.clamp(0.0, 1.0),
                  child: _GlowOrb(
                    size: 420,
                    color: AppColors.accent.withValues(alpha: 0.12),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -120 - orbDriftY * 0.35,
              left: -140 - orbDriftX * 0.25,
              child: IgnorePointer(
                child: Opacity(
                  opacity: (0.93 - orbBreath * 0.12).clamp(0.0, 1.0),
                  child: _GlowOrb(
                    size: 360,
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 120, spreadRadius: 30),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.gridOffsetX,
    required this.gridOffsetY,
    required this.circuitShiftX,
    required this.circuitShiftY,
    required this.circuitPulse,
  });

  final double gridOffsetX;
  final double gridOffsetY;
  final double circuitShiftX;
  final double circuitShiftY;
  final double circuitPulse;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const margin = _kGridSpacing * 2;

    for (double x = -margin + gridOffsetX;
        x <= size.width + margin;
        x += _kGridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = -margin + gridOffsetY;
        y <= size.height + margin;
        y += _kGridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final circuitPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.22 * circuitPulse)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final random = Random(7);
    canvas.save();
    canvas.translate(circuitShiftX, circuitShiftY);
    for (var i = 0; i < 18; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final midX = (startX + random.nextDouble() * 220)
          .clamp(0, size.width)
          .toDouble();
      final endY = (startY + random.nextDouble() * 160)
          .clamp(0, size.height)
          .toDouble();

      final path = Path()
        ..moveTo(startX, startY)
        ..lineTo(midX, startY)
        ..lineTo(midX, endY);

      canvas.drawPath(path, circuitPaint);
      canvas.drawCircle(
        Offset(midX, endY),
        2.6,
        Paint()
          ..color = AppColors.accent.withValues(alpha: 0.28 * circuitPulse),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.gridOffsetX != gridOffsetX ||
        oldDelegate.gridOffsetY != gridOffsetY ||
        oldDelegate.circuitShiftX != circuitShiftX ||
        oldDelegate.circuitShiftY != circuitShiftY ||
        oldDelegate.circuitPulse != circuitPulse;
  }
}
