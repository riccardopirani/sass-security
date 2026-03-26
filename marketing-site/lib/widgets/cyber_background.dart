import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_theme.dart';

const double _kGridSpacing = 42.0;

/// Full-viewport cyber aesthetic. Set [animated] only where motion is desired (e.g. home).
class CyberBackground extends StatelessWidget {
  const CyberBackground({super.key, this.animated = false});

  /// When true, runs a continuous slow animation. When false, no ticker (static backdrop).
  final bool animated;

  @override
  Widget build(BuildContext context) {
    if (animated) {
      return const _AnimatedCyberBackground();
    }
    return const _CyberBackgroundLayers(
      gx: 0,
      gy: 0,
      gridOffsetX: 0,
      gridOffsetY: 0,
      circuitShiftX: 0,
      circuitShiftY: 0,
      circuitPulse: 0.88,
      orbTopExtraY: 0,
      orbTopExtraX: 0,
      orbBottomExtraY: 0,
      orbBottomExtraX: 0,
      orbTopOpacity: 0.92,
      orbBottomOpacity: 0.90,
    );
  }
}

/// Slow, time-based motion (no loop jump).
class _AnimatedCyberBackground extends StatefulWidget {
  const _AnimatedCyberBackground();

  @override
  State<_AnimatedCyberBackground> createState() => _AnimatedCyberBackgroundState();
}

class _AnimatedCyberBackgroundState extends State<_AnimatedCyberBackground>
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

        // Slower drift (px/s) — ~2.5–3× slower than before
        const vx = 0.42;
        const vy = 0.26;
        final gridOffsetX = (sec * vx) % _kGridSpacing;
        final gridOffsetY = (sec * vy) % _kGridSpacing;

        const gradientRadPerSec = 0.016;
        final angle = sec * gradientRadPerSec;
        const gradAmp = 0.1;
        final gx = gradAmp * cos(angle);
        final gy = gradAmp * sin(angle);

        const circuitVx = 0.2;
        const circuitVy = 0.14;
        final circuitShiftX = (sec * circuitVx) % _kGridSpacing;
        final circuitShiftY = (sec * circuitVy) % _kGridSpacing;
        final circuitPulse = 0.78 + 0.22 * sin(sec * 0.14);

        const orbRad = 0.042;
        final orbDriftX = 28 * sin(sec * orbRad * 0.85);
        final orbDriftY = 22 * cos(sec * orbRad * 0.65);
        final orbBreath = 0.88 + 0.12 * sin(sec * 0.08);

        return _CyberBackgroundLayers(
          gx: gx,
          gy: gy,
          gridOffsetX: gridOffsetX,
          gridOffsetY: gridOffsetY,
          circuitShiftX: circuitShiftX,
          circuitShiftY: circuitShiftY,
          circuitPulse: circuitPulse,
          orbTopExtraY: orbDriftY * 0.4,
          orbTopExtraX: orbDriftX * 0.3,
          orbBottomExtraY: -orbDriftY * 0.35,
          orbBottomExtraX: -orbDriftX * 0.25,
          orbTopOpacity: orbBreath.clamp(0.0, 1.0),
          orbBottomOpacity: (0.93 - orbBreath * 0.12).clamp(0.0, 1.0),
        );
      },
    );
  }
}

class _CyberBackgroundLayers extends StatelessWidget {
  const _CyberBackgroundLayers({
    required this.gx,
    required this.gy,
    required this.gridOffsetX,
    required this.gridOffsetY,
    required this.circuitShiftX,
    required this.circuitShiftY,
    required this.circuitPulse,
    required this.orbTopExtraY,
    required this.orbTopExtraX,
    required this.orbBottomExtraY,
    required this.orbBottomExtraX,
    required this.orbTopOpacity,
    required this.orbBottomOpacity,
  });

  final double gx;
  final double gy;
  final double gridOffsetX;
  final double gridOffsetY;
  final double circuitShiftX;
  final double circuitShiftY;
  final double circuitPulse;
  final double orbTopExtraY;
  final double orbTopExtraX;
  final double orbBottomExtraY;
  final double orbBottomExtraX;
  final double orbTopOpacity;
  final double orbBottomOpacity;

  @override
  Widget build(BuildContext context) {
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
          top: -180 + orbTopExtraY,
          right: -140 + orbTopExtraX,
          child: IgnorePointer(
            child: Opacity(
              opacity: orbTopOpacity,
              child: _GlowOrb(
                size: 420,
                color: AppColors.accent.withValues(alpha: 0.12),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -120 + orbBottomExtraY,
          left: -140 + orbBottomExtraX,
          child: IgnorePointer(
            child: Opacity(
              opacity: orbBottomOpacity,
              child: _GlowOrb(
                size: 360,
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.08),
              ),
            ),
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
