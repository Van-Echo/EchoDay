import '../local_date.dart';
import '../recurrence_series.dart';

abstract interface class RecurrenceRepository {
  Stream<List<RecurrenceSeries>> watchAll();
  Future<List<RecurrenceSeries>> getAll();
  Future<RecurrenceSeries?> getById(String id);
  Future<RecurrenceSeries> create(LocalDate startDate, RecurrenceRule rule);
  Future<RecurrenceSeries> save(RecurrenceSeries series);
  Future<void> truncateBefore(String id, LocalDate firstExcludedDate);
  Future<void> softDelete(String id, {DateTime? at});
}
