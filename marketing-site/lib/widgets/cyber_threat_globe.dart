import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

part 'cyber_threat_globe_continents.dart';

/// City on Earth (WGS84 degrees).
class _GeoPoint {
  const _GeoPoint(this.latDeg, this.lonDeg);

  final double latDeg;
  final double lonDeg;

  @override
  bool operator ==(Object other) =>
      other is _GeoPoint &&
      other.latDeg == latDeg &&
      other.lonDeg == lonDeg;

  @override
  int get hashCode => Object.hash(latDeg, lonDeg);
}

/// Directed corridor (source → target) shown as a curved link on the globe.
class _ThreatLink {
  const _ThreatLink(this.from, this.to);

  final _GeoPoint from;
  final _GeoPoint to;
}

/// Demo “live” corridors — illustrative only for the marketing hero.
const List<_ThreatLink> _kDemoLinks = [
  _ThreatLink(_GeoPoint(55.76, 37.62), _GeoPoint(50.11, 8.68)), // Moscow → Frankfurt
  _ThreatLink(_GeoPoint(51.51, -0.13), _GeoPoint(40.71, -74.01)), // London → NYC
  _ThreatLink(_GeoPoint(35.68, 139.76), _GeoPoint(1.35, 103.82)), // Tokyo → Singapore
  _ThreatLink(_GeoPoint(-33.87, 151.21), _GeoPoint(19.08, 72.88)), // Sydney → Mumbai
  _ThreatLink(_GeoPoint(-23.55, -46.63), _GeoPoint(40.71, -74.01)), // São Paulo → NYC
  _ThreatLink(_GeoPoint(48.86, 2.35), _GeoPoint(52.52, 13.41)), // Paris → Berlin
];

class _Projected {
  const _Projected(this.offset, this.z);

  final Offset offset;
  final double z;
}

_Projected _project(
  _GeoPoint p,
  double rotationRad,
  Offset center,
  double radius,
) {
  final lat = p.latDeg * pi / 180;
  final lon = p.lonDeg * pi / 180 + rotationRad;
  final cl = cos(lat);
  final x = cl * sin(lon);
  final z = cl * cos(lon);
  final y = sin(lat);
  final r = radius * 0.9;
  return _Projected(
    Offset(center.dx + r * x, center.dy - r * y),
    z,
  );
}

Path _continentsRingPath(
  List<_GeoPoint> ring,
  double rotation,
  Offset center,
  double radius,
  double visibleZ, {
  int subdivisionsPerEdge = 16,
}) {
  final path = Path();
  var penUp = true;
  for (var i = 0; i < ring.length; i++) {
    final a = ring[i];
    final b = ring[(i + 1) % ring.length];
    for (var s = 0; s <= subdivisionsPerEdge; s++) {
      final t = s / subdivisionsPerEdge;
      final lat = a.latDeg + (b.latDeg - a.latDeg) * t;
      final lon = a.lonDeg + (b.lonDeg - a.lonDeg) * t;
      final p = _project(_GeoPoint(lat, lon), rotation, center, radius);
      if (p.z >= visibleZ) {
        if (penUp) {
          path.moveTo(p.offset.dx, p.offset.dy);
          penUp = false;
        } else {
          path.lineTo(p.offset.dx, p.offset.dy);
        }
      } else {
        penUp = true;
      }
    }
  }
  return path;
}

void _paintContinentLandmasses(
  Canvas canvas,
  Offset center,
  double radius,
  double rotation,
  double visibleZ,
) {
  // Slightly coarser grid on web: fewer drawCircle calls per frame.
  final step = kIsWeb ? 4.2 : 3.4;
  final fillAccent = Paint()..color = AppColors.accent.withValues(alpha: 0.042);
  final fillSoft = Paint()..color = Colors.white.withValues(alpha: 0.058);

  for (var lat = -56.0; lat <= 76.0; lat += step) {
    for (var lon = -178.0; lon <= 178.0; lon += step) {
      if (!_isLandCell(lat, lon)) continue;
      final p = _project(_GeoPoint(lat, lon), rotation, center, radius);
      if (p.z < visibleZ) continue;
      canvas.drawCircle(p.offset, 1.5, fillSoft);
      canvas.drawCircle(p.offset, 0.95, fillAccent);
    }
  }

  final outlineGlow = Paint()
    ..color = AppColors.accent.withValues(alpha: kIsWeb ? 0.16 : 0.11)
    ..style = PaintingStyle.stroke
    ..strokeWidth = kIsWeb ? 3.2 : 2.5
    ..strokeJoin = StrokeJoin.round;
  if (!kIsWeb) {
    outlineGlow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2);
  }
  final outline = Paint()
    ..color = AppColors.accent.withValues(alpha: 0.24)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.05
    ..strokeJoin = StrokeJoin.round;

  for (final ring in _kContinentRings) {
    final path = _continentsRingPath(
      ring,
      rotation,
      center,
      radius,
      visibleZ,
    );
    final bb = path.getBounds();
    if (bb.width <= 0 && bb.height <= 0) continue;
    canvas.drawPath(path, outlineGlow);
    canvas.drawPath(path, outline);
  }
}

/// Orthographic globe with accent “threat” arcs between cities; matches [AppColors] cyber look.
class CyberThreatGlobe extends StatefulWidget {
  const CyberThreatGlobe({super.key, required this.size});

  final double size;

  @override
  State<CyberThreatGlobe> createState() => _CyberThreatGlobeState();
}

class _CyberThreatGlobeState extends State<CyberThreatGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 140),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final v = _controller.value;
            return CustomPaint(
              painter: _GlobePainter(
                rotation: v * 2 * pi,
                // Several wave cycles per full spin so arcs/nodes feel “alive”
                pulsePhase: v * 2 * pi * 28,
              ),
              size: Size(widget.size, widget.size),
            );
          },
        ),
      ),
    );
  }
}

class _GlobePainter extends CustomPainter {
  _GlobePainter({
    required this.rotation,
    required this.pulsePhase,
  });

  final double rotation;
  final double pulsePhase;

  static const _visibleZ = -0.12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clipPath);

    // Sphere body
    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF0D1528),
          AppColors.background,
          const Color(0xFF111C32),
          AppColors.accent.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.45, 0.82, 1.0],
        center: const Alignment(-0.35, -0.35),
        radius: 1.05,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    // Continents: dotted landmass + accent coast outlines (same rotation as globe)
    _paintContinentLandmasses(canvas, center, radius, rotation, _visibleZ);

    // Subtle latitude rings
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.045)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (var i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final sy = center.dy + (i / 3) * radius * 0.78;
      final w = radius * sqrt(max(0, 1 - pow((i / 3) * 0.78, 2)));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(center.dx, sy), width: w * 2, height: w * 0.28),
        gridPaint,
      );
    }

    // Meridians (partial great circles, front hemisphere only)
    final meridianPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    for (var i = 0; i < 5; i++) {
      final lon = rotation + (i / 5) * pi;
      final path = Path();
      var started = false;
      for (var t = -0.9; t <= 0.901; t += 0.05) {
        final lat = t * pi * 0.44;
        final cl = cos(lat);
        final x = cl * sin(lon);
        final z = cl * cos(lon);
        final y = sin(lat);
        if (z < _visibleZ) {
          started = false;
          continue;
        }
        final pt = Offset(
          center.dx + radius * 0.9 * x,
          center.dy - radius * 0.9 * y,
        );
        if (!started) {
          path.moveTo(pt.dx, pt.dy);
          started = true;
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      final mb = path.getBounds();
      if (mb.width > 0 || mb.height > 0) {
        canvas.drawPath(path, meridianPaint);
      }
    }

    // Threat arcs (draw before nodes so lines sit “on” globe)
    for (var i = 0; i < _kDemoLinks.length; i++) {
      final link = _kDemoLinks[i];
      final a = _project(link.from, rotation, center, radius);
      final b = _project(link.to, rotation, center, radius);
      if (a.z < _visibleZ || b.z < _visibleZ) continue;

      final mid = Offset((a.offset.dx + b.offset.dx) / 2, (a.offset.dy + b.offset.dy) / 2);
      final chord = b.offset - a.offset;
      final perp = chord.distance > 1 ? Offset(-chord.dy, chord.dx) / chord.distance : Offset.zero;
      final outward = mid - center;
      final sign = outward.dx * perp.dy - outward.dy * perp.dx >= 0 ? 1.0 : -1.0;
      final bulge = radius * 0.32;
      final control = mid + perp * bulge * sign;

      final phase = pulsePhase * 1.15 + i * 0.55;
      final flow = (sin(phase) * 0.5 + 0.5).clamp(0.0, 1.0);
      final alpha = 0.22 + 0.38 * flow;

      final arcPath = Path()
        ..moveTo(a.offset.dx, a.offset.dy)
        ..quadraticBezierTo(control.dx, control.dy, b.offset.dx, b.offset.dy);

      final arcGlow = Paint()
        ..color = AppColors.accent.withValues(alpha: alpha * (kIsWeb ? 0.28 : 0.45))
        ..style = PaintingStyle.stroke
        ..strokeWidth = kIsWeb ? 3.4 : 2.2;
      if (!kIsWeb) {
        arcGlow.maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      }
      canvas.drawPath(arcPath, arcGlow);
      canvas.drawPath(
        arcPath,
        Paint()
          ..color = AppColors.accent.withValues(alpha: alpha * 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }

    // Nodes
    final nodes = <_GeoPoint>{};
    for (final link in _kDemoLinks) {
      nodes.add(link.from);
      nodes.add(link.to);
    }
    for (final city in nodes) {
      final p = _project(city, rotation, center, radius);
      if (p.z < _visibleZ) continue;

      final nPhase = pulsePhase * 1.8 + city.latDeg * 0.01 + city.lonDeg * 0.01;
      final glow = 0.55 + 0.45 * (0.5 + 0.5 * sin(nPhase));

      final nodeHalo = Paint()
        ..color = AppColors.accent.withValues(alpha: (kIsWeb ? 0.18 : 0.12) * glow);
      if (!kIsWeb) {
        nodeHalo.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      }
      canvas.drawCircle(
        p.offset,
        kIsWeb ? 9.0 : 7.0,
        nodeHalo,
      );
      canvas.drawCircle(
        p.offset,
        3.2,
        Paint()..color = AppColors.accent.withValues(alpha: 0.95 * glow),
      );
      canvas.drawCircle(
        p.offset,
        1.2,
        Paint()..color = Colors.white.withValues(alpha: 0.85),
      );
    }

    // Rim
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.accent.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _GlobePainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.pulsePhase != pulsePhase;
  }
}
