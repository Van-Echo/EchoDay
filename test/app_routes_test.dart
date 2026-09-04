import 'package:echoday/src/app/router/app_routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats a stable local date route', () {
    expect(AppRoutes.dayTodosFor(DateTime(2026, 9, 3)), '/day/2026-09-03');
  });
}
