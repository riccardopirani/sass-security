import 'package:flutter/material.dart';

/// Centers app pages and caps width on ultra-wide screens; responsive horizontal inset.
class ShellContent extends StatelessWidget {
  const ShellContent({required this.child, super.key});

  final Widget child;

  static double horizontalPaddingForWidth(double width) {
    if (width >= 1400) return 40;
    if (width >= 900) return 28;
    if (width >= 600) return 20;
    return 16;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final hPad = horizontalPaddingForWidth(w);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1480),
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 24),
          child: child,
        ),
      ),
    );
  }
}
