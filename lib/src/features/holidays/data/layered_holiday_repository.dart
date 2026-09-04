import '../domain/holiday_repository.dart';
import '../domain/holiday_year.dart';
import 'holiday_sources.dart';
import 'holiday_year_codec.dart';

final class LayeredHolidayRepository implements HolidayRepository {
  const LayeredHolidayRepository(
    this._cached, [
    this._bundled = const BundledHolidaySource(),
    this._remote = const UnconfiguredRemoteHolidaySource(),
    this._codec = const HolidayYearCodec(),
  ]);

  final CachedHolidaySource _cached;
  final BundledHolidaySource _bundled;
  final RemoteHolidaySource _remote;
  final HolidayYearCodec _codec;

  @override
  Future<HolidayYear?> getYear(int year) async {
    final cached = await _cached.getYear(year);
    if (cached != null) return cached;
    final bundled = await _bundled.getYear(year);
    if (bundled != null) await _cached.save(bundled);
    return bundled;
  }

  @override
  Future<Set<int>> getAvailableYears() async {
    return {
      ...BundledHolidaySource.availableYears,
      ...await _cached.getAvailableYears(),
    };
  }

  @override
  Future<HolidayRefreshResult> refresh(int year) async {
    final local = await _cached.getYear(year) ?? await _loadBundled(year);
    final payload = await _remote.fetchYear(year);
    if (payload == null) {
      return HolidayRefreshResult(
        HolidayRefreshStatus.unavailable,
        year: local,
      );
    }
    late final HolidayYear decoded;
    try {
      decoded = _codec.decode(payload);
      if (decoded.year != year) throw const FormatException('Year mismatch.');
    } on FormatException {
      return HolidayRefreshResult(
        HolidayRefreshStatus.failedValidation,
        year: local,
      );
    }
    if (local?.checksum == decoded.checksum) {
      return HolidayRefreshResult(HolidayRefreshStatus.unchanged, year: local);
    }
    await _cached.save(decoded);
    return HolidayRefreshResult(HolidayRefreshStatus.updated, year: decoded);
  }

  Future<HolidayYear?> _loadBundled(int year) async {
    final bundled = await _bundled.getYear(year);
    if (bundled != null) await _cached.save(bundled);
    return bundled;
  }
}
