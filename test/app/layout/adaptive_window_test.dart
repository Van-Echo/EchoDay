import 'package:echoday/src/app/layout/adaptive_window.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies the documented Android width breakpoints', () {
    expect(AdaptiveWindow.classify(0), AdaptiveWindowClass.compact);
    expect(AdaptiveWindow.classify(599), AdaptiveWindowClass.compact);
    expect(AdaptiveWindow.classify(600), AdaptiveWindowClass.medium);
    expect(AdaptiveWindow.classify(839), AdaptiveWindowClass.medium);
    expect(AdaptiveWindow.classify(840), AdaptiveWindowClass.expanded);
    expect(AdaptiveWindow.classify(1200), AdaptiveWindowClass.expanded);
  });
}
