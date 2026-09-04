typedef UtcClock = DateTime Function();

DateTime systemUtcClock() => DateTime.now().toUtc();

DateTime requireUtc(DateTime value, String fieldName) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, fieldName, 'must be a UTC DateTime');
  }
  return value;
}
