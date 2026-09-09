import 'android_holiday_network_test.dart' as holiday;
import 'android_performance_test.dart' as performance;
import 'android_quality_test.dart' as quality;
import 'android_timezone_test.dart' as timezone;

/// Runs the complete S8 physical-device suite from one APK installation.
///
/// This matters on Android distributions that ask the user to approve every
/// USB package replacement, while keeping each focused test independently
/// runnable for diagnostics.
void main() {
  quality.main();
  timezone.main();
  performance.main();
  holiday.main();
}
