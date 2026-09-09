final class HybridTimestamp implements Comparable<HybridTimestamp> {
  const HybridTimestamp({
    required this.physicalMillisUtc,
    required this.logicalCounter,
    required this.deviceId,
  }) : assert(physicalMillisUtc >= 0),
       assert(logicalCounter >= 0),
       assert(deviceId != '');

  factory HybridTimestamp.fromJson(Map<String, dynamic> json) {
    final physicalMillisUtc = json['physicalMillisUtc'];
    final logicalCounter = json['logicalCounter'];
    final deviceId = json['deviceId'];
    if (physicalMillisUtc is! int ||
        physicalMillisUtc < 0 ||
        logicalCounter is! int ||
        logicalCounter < 0 ||
        deviceId is! String ||
        deviceId.trim().isEmpty) {
      throw const FormatException('Invalid hybrid logical timestamp.');
    }
    return HybridTimestamp(
      physicalMillisUtc: physicalMillisUtc,
      logicalCounter: logicalCounter,
      deviceId: deviceId,
    );
  }

  final int physicalMillisUtc;
  final int logicalCounter;
  final String deviceId;

  Map<String, dynamic> toJson() => {
    'physicalMillisUtc': physicalMillisUtc,
    'logicalCounter': logicalCounter,
    'deviceId': deviceId,
  };

  @override
  int compareTo(HybridTimestamp other) {
    final physical = physicalMillisUtc.compareTo(other.physicalMillisUtc);
    if (physical != 0) return physical;
    final logical = logicalCounter.compareTo(other.logicalCounter);
    if (logical != 0) return logical;
    return deviceId.compareTo(other.deviceId);
  }

  @override
  bool operator ==(Object other) =>
      other is HybridTimestamp &&
      physicalMillisUtc == other.physicalMillisUtc &&
      logicalCounter == other.logicalCounter &&
      deviceId == other.deviceId;

  @override
  int get hashCode => Object.hash(physicalMillisUtc, logicalCounter, deviceId);

  @override
  String toString() => '$physicalMillisUtc:$logicalCounter:$deviceId';
}

/// Stateful HLC used by one device.
///
/// Wall time is never trusted as a total ordering source: it is combined with
/// a logical counter and the stable device id.
final class HybridLogicalClock {
  HybridLogicalClock({
    required this.deviceId,
    int Function()? wallClockMillisUtc,
    HybridTimestamp? initial,
  }) : _wallClockMillisUtc =
           wallClockMillisUtc ??
           (() => DateTime.now().toUtc().millisecondsSinceEpoch),
       _lastPhysicalMillisUtc = initial?.physicalMillisUtc ?? 0,
       _lastLogicalCounter = initial?.logicalCounter ?? 0 {
    if (deviceId.trim().isEmpty) {
      throw ArgumentError.value(deviceId, 'deviceId', 'must not be blank');
    }
    if (initial != null && initial.deviceId != deviceId) {
      throw ArgumentError('Initial timestamp belongs to another device.');
    }
  }

  final String deviceId;
  final int Function() _wallClockMillisUtc;
  int _lastPhysicalMillisUtc;
  int _lastLogicalCounter;

  HybridTimestamp get current => HybridTimestamp(
    physicalMillisUtc: _lastPhysicalMillisUtc,
    logicalCounter: _lastLogicalCounter,
    deviceId: deviceId,
  );

  HybridTimestamp tick() {
    final wall = _checkedWallTime();
    if (wall > _lastPhysicalMillisUtc) {
      _lastPhysicalMillisUtc = wall;
      _lastLogicalCounter = 0;
    } else {
      _lastLogicalCounter++;
    }
    return current;
  }

  HybridTimestamp receive(HybridTimestamp remote) {
    final wall = _checkedWallTime();
    final previousPhysical = _lastPhysicalMillisUtc;
    final physical = [
      wall,
      previousPhysical,
      remote.physicalMillisUtc,
    ].reduce((left, right) => left > right ? left : right);

    if (physical == previousPhysical && physical == remote.physicalMillisUtc) {
      _lastLogicalCounter =
          (_lastLogicalCounter > remote.logicalCounter
              ? _lastLogicalCounter
              : remote.logicalCounter) +
          1;
    } else if (physical == previousPhysical) {
      _lastLogicalCounter++;
    } else if (physical == remote.physicalMillisUtc) {
      _lastLogicalCounter = remote.logicalCounter + 1;
    } else {
      _lastLogicalCounter = 0;
    }
    _lastPhysicalMillisUtc = physical;
    return current;
  }

  int _checkedWallTime() {
    final value = _wallClockMillisUtc();
    if (value < 0) {
      throw StateError('Wall clock must be on or after the Unix epoch.');
    }
    return value;
  }
}
