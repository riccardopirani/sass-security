import 'package:cyberguard_marketing/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders CyberGuard app shell', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CyberGuardApp()));
    await tester.pumpAndSettle();

    expect(find.textContaining('CyberGuard'), findsWidgets);
  });
}
