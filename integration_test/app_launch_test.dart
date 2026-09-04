import 'package:echoday/src/app/echoday_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('launches the Windows application shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: EchoDayApp(locale: Locale('zh'))),
    );
    await tester.pumpAndSettle();

    expect(find.text('丸成'), findsOneWidget);
    expect(find.text('月历工作台'), findsWidgets);
  });
}
