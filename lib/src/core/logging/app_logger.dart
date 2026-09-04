import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

abstract final class AppLogger {
  static final Logger _logger = Logger('EchoDay');

  static void info(String message) {
    _logger.info(message);
  }

  static void error(String message, Object error, StackTrace? stackTrace) {
    _logger.severe(message, error, stackTrace);
  }
}

void configureLogging() {
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.time.toIso8601String()} '
      '[${record.level.name}] ${record.loggerName}: ${record.message}',
    );
    if (record.error != null) {
      debugPrint('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrintStack(stackTrace: record.stackTrace);
    }
  });
}
