import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sass_security/app.dart';
import 'package:sass_security/core/localization/locale_controller.dart';

void main() {
  testWidgets('shows marketing landing first', (tester) async {
    await tester.pumpWidget(
      CyberGuardApp(
        localeController: LocaleController(const Locale('en')),
        backendReady: true,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Cybersecurity platform for SMB teams'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
