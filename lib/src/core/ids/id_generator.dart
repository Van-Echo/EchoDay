import 'package:uuid/uuid.dart';

abstract interface class IdGenerator {
  String next();
}

final class UuidV7Generator implements IdGenerator {
  const UuidV7Generator();

  static const Uuid _uuid = Uuid();

  @override
  String next() => _uuid.v7();
}
