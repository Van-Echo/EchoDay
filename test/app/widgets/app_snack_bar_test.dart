import 'package:echoday/src/app/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('feedback with an undo action disappears after three seconds', (
    tester,
  ) async {
    final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: scaffoldKey,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppSnackBar(
                context,
                '任务已删除',
                action: SnackBarAction(label: '撤销', onPressed: () {}),
              ),
              child: const Text('删除'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('删除'));
    await tester.pump();
    expect(find.text('任务已删除'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 3));
    expect(snackBar.persist, isFalse);

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('任务已删除'), findsNothing);
  });
}
