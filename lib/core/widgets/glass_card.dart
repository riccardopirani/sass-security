import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({required this.child, this.padding, super.key});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xCC1F2937), Color(0xCC111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF374151)),
      ),
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}
