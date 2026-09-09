import 'package:echoday/src/features/sync/domain/hybrid_logical_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('local clock stays monotonic when wall time moves backwards', () {
    var wall = 2000;
    final clock = HybridLogicalClock(
      deviceId: 'device-a',
      wallClockMillisUtc: () => wall,
    );

    final first = clock.tick();
    wall = 1500;
    final second = clock.tick();

    expect(
      first,
      const HybridTimestamp(
        physicalMillisUtc: 2000,
        logicalCounter: 0,
        deviceId: 'device-a',
      ),
    );
    expect(second.physicalMillisUtc, 2000);
    expect(second.logicalCounter, 1);
    expect(second.compareTo(first), greaterThan(0));
  });

  test('receiving a future timestamp advances logical time', () {
    final clock = HybridLogicalClock(
      deviceId: 'device-a',
      wallClockMillisUtc: () => 1000,
    );
    final received = clock.receive(
      const HybridTimestamp(
        physicalMillisUtc: 5000,
        logicalCounter: 7,
        deviceId: 'device-b',
      ),
    );

    expect(received.physicalMillisUtc, 5000);
    expect(received.logicalCounter, 8);
    expect(received.deviceId, 'device-a');
  });

  test('device id provides a stable final tie break', () {
    const left = HybridTimestamp(
      physicalMillisUtc: 1000,
      logicalCounter: 2,
      deviceId: 'device-a',
    );
    const right = HybridTimestamp(
      physicalMillisUtc: 1000,
      logicalCounter: 2,
      deviceId: 'device-b',
    );

    expect(left.compareTo(right), lessThan(0));
    expect(HybridTimestamp.fromJson(left.toJson()), left);
  });
}
