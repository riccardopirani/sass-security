import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CtaButton extends StatefulWidget {
  const CtaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;

  @override
  State<CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<CtaButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.filled ? AppColors.accent : Colors.transparent;
    final foreground = widget.filled ? AppColors.background : AppColors.text;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: TextButton.icon(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: widget.filled ? Colors.transparent : AppColors.border,
              ),
            ),
            backgroundColor: color,
            foregroundColor: foreground,
          ),
          icon: widget.icon == null
              ? const SizedBox.shrink()
              : Icon(widget.icon, size: 18),
          label: Text(widget.label),
        ),
      ),
    );
  }
}
