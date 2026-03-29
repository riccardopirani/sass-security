import 'package:flutter/material.dart';

/// Circular avatar: network image when [imageUrl] is set, otherwise initials from [name].
class EmployeeAvatar extends StatelessWidget {
  const EmployeeAvatar({
    required this.name,
    this.imageUrl,
    this.radius = 22,
    this.backgroundColor,
    super.key,
  });

  final String name;
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;

  String get _initial {
    final t = name.trim();
    if (t.isEmpty) return '?';
    return t[0].toUpperCase();
  }

  Widget _fallback() {
    final bg = backgroundColor ?? const Color(0xFF0EA5E9);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return _fallback();
    }
    final d = radius * 2;
    return ClipOval(
      child: SizedBox(
        width: d,
        height: d,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: SizedBox(
                width: radius,
                height: radius,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
