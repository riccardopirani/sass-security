import 'package:flutter/material.dart';

class AppSnack {
  static void success(BuildContext context, String message) {
    _show(context, message, const Color(0xFF10B981));
  }

  static void error(BuildContext context, String message) {
    _show(context, message, const Color(0xFFEF4444));
  }

  static void _show(BuildContext context, String message, Color color) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(backgroundColor: color, content: Text(message)),
    );
  }
}
