import 'dart:convert';

import 'hybrid_logical_clock.dart';

abstract final class SyncProtocol {
  static const version = 1;
  static const targetDatabaseSchemaVersion = 3;
  static const payloadFormatVersion = 1;
  static const maximumBatchOperations = 1000;
  static const maximumDecompressedBytes = 10 * 1024 * 1024;
  static const maximumJsonDepth = 32;
  static const maximumIdentifierLength = 256;
  static const maximumStringLength = 100000;
}

enum SyncEntityType {
  todo('todo'),
  category('category'),
  tag('tag'),
  recurrenceSeries('recurrenceSeries'),
  recurrenceException('recurrenceException'),
  todoTag('todoTag');

  const SyncEntityType(this.wireName);
  final String wireName;
}

enum SyncOperationType {
  upsert('upsert'),
  delete('delete'),
  restore('restore'),
  relationAdd('relationAdd'),
  relationRemove('relationRemove');

  const SyncOperationType(this.wireName);
  final String wireName;
}

enum SyncFieldGroup {
  content('content'),
  completion('completion'),
  order('order'),
  tags('tags'),
  deletion('deletion');

  const SyncFieldGroup(this.wireName);
  final String wireName;
}

enum SyncErrorCode {
  invalidRequest('invalid_request'),
  protocolIncompatible('protocol_incompatible'),
  schemaIncompatible('schema_incompatible'),
  unauthorized('unauthorized'),
  replayDetected('replay_detected'),
  deviceRevoked('device_revoked'),
  inviteExpired('invite_expired'),
  sequenceGap('sequence_gap'),
  payloadTooLarge('payload_too_large'),
  batchTooLarge('batch_too_large'),
  validationFailed('validation_failed'),
  conflict('conflict'),
  internal('internal');

  const SyncErrorCode(this.wireName);
  final String wireName;
}

final class SyncProtocolException implements FormatException {
  const SyncProtocolException(this.code, this.message, [this.source]);

  final SyncErrorCode code;
  @override
  final String message;
  @override
  final dynamic source;
  @override
  int? get offset => null;

  @override
  String toString() => 'SyncProtocolException(${code.wireName}): $message';
}

final class SyncCursor {
  SyncCursor([Map<String, int> sequences = const {}])
    : sequences = Map.unmodifiable(Map.of(sequences)) {
    for (final entry in this.sequences.entries) {
      if (entry.key.trim().isEmpty || entry.value < 0) {
        throw ArgumentError.value(
          sequences,
          'sequences',
          'contains invalid entry',
        );
      }
    }
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json) {
    final sequences = <String, int>{};
    for (final entry in json.entries) {
      if (entry.key.trim().isEmpty ||
          entry.key.length > SyncProtocol.maximumIdentifierLength ||
          entry.value is! int ||
          (entry.value as int) < 0) {
        throw const SyncProtocolException(
          SyncErrorCode.validationFailed,
          'Cursor contains an invalid device or sequence.',
        );
      }
      sequences[entry.key] = entry.value as int;
    }
    return SyncCursor(sequences);
  }

  final Map<String, int> sequences;

  int sequenceFor(String deviceId) => sequences[deviceId] ?? 0;

  bool observes(SyncOperation operation) =>
      sequenceFor(operation.sourceDeviceId) >= operation.sequence;

  SyncCursor advanced(String deviceId, int sequence) {
    if (sequence < sequenceFor(deviceId)) return this;
    return SyncCursor({...sequences, deviceId: sequence});
  }

  SyncCursor mergedWith(SyncCursor other) {
    final result = Map<String, int>.of(sequences);
    for (final entry in other.sequences.entries) {
      final current = result[entry.key] ?? 0;
      if (entry.value > current) result[entry.key] = entry.value;
    }
    return SyncCursor(result);
  }

  Map<String, dynamic> toJson() => Map<String, int>.from(sequences);

  @override
  bool operator ==(Object other) =>
      other is SyncCursor && _mapEquals(sequences, other.sequences);

  @override
  int get hashCode {
    final entries = sequences.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));
    return Object.hashAll(
      entries.map((entry) => Object.hash(entry.key, entry.value)),
    );
  }
}

final class SyncOperation {
  SyncOperation({
    required this.operationId,
    required this.syncGroupId,
    required this.sourceDeviceId,
    required this.sequence,
    required this.transactionId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.fieldGroup,
    required Map<String, dynamic> payload,
    required this.timestamp,
    required this.causalCursor,
    required this.createdAtUtc,
    this.protocolVersion = SyncProtocol.version,
    this.schemaVersion = SyncProtocol.targetDatabaseSchemaVersion,
    this.payloadFormatVersion = SyncProtocol.payloadFormatVersion,
  }) : payload = Map.unmodifiable(Map.of(payload));

  final int protocolVersion;
  final int schemaVersion;
  final int payloadFormatVersion;
  final String operationId;
  final String syncGroupId;
  final String sourceDeviceId;
  final int sequence;
  final String transactionId;
  final SyncEntityType entityType;
  final String entityId;
  final SyncOperationType operationType;
  final SyncFieldGroup fieldGroup;
  final Map<String, dynamic> payload;
  final HybridTimestamp timestamp;
  final SyncCursor causalCursor;
  final DateTime createdAtUtc;

  Map<String, dynamic> toJson() => {
    'protocolVersion': protocolVersion,
    'schemaVersion': schemaVersion,
    'payloadFormatVersion': payloadFormatVersion,
    'operationId': operationId,
    'syncGroupId': syncGroupId,
    'sourceDeviceId': sourceDeviceId,
    'sequence': sequence,
    'transactionId': transactionId,
    'entityType': entityType.wireName,
    'entityId': entityId,
    'operationType': operationType.wireName,
    'fieldGroup': fieldGroup.wireName,
    'payload': payload,
    'timestamp': timestamp.toJson(),
    'causalCursor': causalCursor.toJson(),
    'createdAtUtc': createdAtUtc.toIso8601String(),
  };
}

final class SyncBatch {
  SyncBatch({
    required this.syncGroupId,
    required this.senderDeviceId,
    required this.cursor,
    required List<SyncOperation> operations,
    this.protocolVersion = SyncProtocol.version,
    this.schemaVersion = SyncProtocol.targetDatabaseSchemaVersion,
  }) : operations = List.unmodifiable(operations);

  final int protocolVersion;
  final int schemaVersion;
  final String syncGroupId;
  final String senderDeviceId;
  final SyncCursor cursor;
  final List<SyncOperation> operations;

  Map<String, dynamic> toJson() => {
    'protocolVersion': protocolVersion,
    'schemaVersion': schemaVersion,
    'syncGroupId': syncGroupId,
    'senderDeviceId': senderDeviceId,
    'cursor': cursor.toJson(),
    'operations': operations.map((operation) => operation.toJson()).toList(),
  };
}

abstract final class SyncProtocolCodec {
  static String encodeOperation(SyncOperation operation) {
    SyncProtocolValidator.validateOperation(operation);
    return jsonEncode(operation.toJson());
  }

  static SyncOperation decodeOperation(String source) {
    final decoded = _decodeObject(source);
    return operationFromJson(decoded);
  }

  static SyncOperation operationFromJson(Map<String, dynamic> json) {
    final createdAtValue = _string(json, 'createdAtUtc');
    final createdAt = DateTime.tryParse(createdAtValue);
    if (createdAt == null || !createdAt.isUtc) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'createdAtUtc must be a UTC ISO-8601 timestamp.',
      );
    }
    final operation = SyncOperation(
      protocolVersion: _integer(json, 'protocolVersion'),
      schemaVersion: _integer(json, 'schemaVersion'),
      payloadFormatVersion: _integer(json, 'payloadFormatVersion'),
      operationId: _string(json, 'operationId'),
      syncGroupId: _string(json, 'syncGroupId'),
      sourceDeviceId: _string(json, 'sourceDeviceId'),
      sequence: _integer(json, 'sequence'),
      transactionId: _string(json, 'transactionId'),
      entityType: _enumValue(
        SyncEntityType.values,
        _string(json, 'entityType'),
        (value) => value.wireName,
      ),
      entityId: _string(json, 'entityId'),
      operationType: _enumValue(
        SyncOperationType.values,
        _string(json, 'operationType'),
        (value) => value.wireName,
      ),
      fieldGroup: _enumValue(
        SyncFieldGroup.values,
        _string(json, 'fieldGroup'),
        (value) => value.wireName,
      ),
      payload: _object(json, 'payload'),
      timestamp: _timestamp(_object(json, 'timestamp')),
      causalCursor: SyncCursor.fromJson(_object(json, 'causalCursor')),
      createdAtUtc: createdAt,
    );
    SyncProtocolValidator.validateOperation(operation);
    return operation;
  }

  static String encodeBatch(SyncBatch batch) {
    SyncProtocolValidator.validateBatch(batch);
    final encoded = jsonEncode(batch.toJson());
    if (utf8.encode(encoded).length > SyncProtocol.maximumDecompressedBytes) {
      throw const SyncProtocolException(
        SyncErrorCode.payloadTooLarge,
        'Decompressed batch exceeds the size limit.',
      );
    }
    return encoded;
  }

  static SyncBatch decodeBatch(String source) {
    if (utf8.encode(source).length > SyncProtocol.maximumDecompressedBytes) {
      throw const SyncProtocolException(
        SyncErrorCode.payloadTooLarge,
        'Decompressed batch exceeds the size limit.',
      );
    }
    final json = _decodeObject(source);
    final values = json['operations'];
    if (values is! List) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'operations must be an array.',
      );
    }
    final batch = SyncBatch(
      protocolVersion: _integer(json, 'protocolVersion'),
      schemaVersion: _integer(json, 'schemaVersion'),
      syncGroupId: _string(json, 'syncGroupId'),
      senderDeviceId: _string(json, 'senderDeviceId'),
      cursor: SyncCursor.fromJson(_object(json, 'cursor')),
      operations: values
          .map((value) {
            if (value is! Map<String, dynamic>) {
              throw const SyncProtocolException(
                SyncErrorCode.validationFailed,
                'operations contains a non-object value.',
              );
            }
            return operationFromJson(value);
          })
          .toList(growable: false),
    );
    SyncProtocolValidator.validateBatch(batch);
    return batch;
  }

  static Map<String, dynamic> _decodeObject(String source) {
    try {
      final value = jsonDecode(source);
      if (value is! Map<String, dynamic>) {
        throw const SyncProtocolException(
          SyncErrorCode.validationFailed,
          'The root value must be an object.',
        );
      }
      return value;
    } on SyncProtocolException {
      rethrow;
    } on Object catch (error) {
      throw SyncProtocolException(
        SyncErrorCode.invalidRequest,
        'Invalid JSON.',
        error,
      );
    }
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        '$key must be an integer.',
      );
    }
    return value;
  }

  static String _string(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        '$key must be a string.',
      );
    }
    return value;
  }

  static Map<String, dynamic> _object(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! Map<String, dynamic>) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        '$key must be an object.',
      );
    }
    return value;
  }

  static T _enumValue<T>(
    List<T> values,
    String wireName,
    String Function(T value) nameOf,
  ) {
    for (final value in values) {
      if (nameOf(value) == wireName) return value;
    }
    throw SyncProtocolException(
      SyncErrorCode.validationFailed,
      'Unknown enum value: $wireName.',
    );
  }

  static HybridTimestamp _timestamp(Map<String, dynamic> json) {
    try {
      return HybridTimestamp.fromJson(json);
    } on FormatException catch (error) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Invalid hybrid logical timestamp.',
        error,
      );
    }
  }
}

abstract final class SyncProtocolValidator {
  static void validateBatch(SyncBatch batch) {
    _versions(batch.protocolVersion, batch.schemaVersion);
    _identifier(batch.syncGroupId, 'syncGroupId');
    _identifier(batch.senderDeviceId, 'senderDeviceId');
    if (batch.operations.length > SyncProtocol.maximumBatchOperations) {
      throw const SyncProtocolException(
        SyncErrorCode.batchTooLarge,
        'Batch contains too many operations.',
      );
    }
    final operationIds = <String>{};
    for (final operation in batch.operations) {
      validateOperation(operation);
      if (operation.syncGroupId != batch.syncGroupId) {
        throw const SyncProtocolException(
          SyncErrorCode.validationFailed,
          'Operation belongs to another sync group.',
        );
      }
      if (!operationIds.add(operation.operationId)) {
        throw const SyncProtocolException(
          SyncErrorCode.replayDetected,
          'Batch contains a duplicate operation id.',
        );
      }
    }
  }

  static void validateOperation(SyncOperation operation) {
    _versions(operation.protocolVersion, operation.schemaVersion);
    if (operation.payloadFormatVersion != SyncProtocol.payloadFormatVersion) {
      throw const SyncProtocolException(
        SyncErrorCode.protocolIncompatible,
        'Unsupported payload format version.',
      );
    }
    _identifier(operation.operationId, 'operationId');
    _identifier(operation.syncGroupId, 'syncGroupId');
    _identifier(operation.sourceDeviceId, 'sourceDeviceId');
    _identifier(operation.transactionId, 'transactionId');
    _identifier(operation.entityId, 'entityId');
    if (operation.sequence < 1) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'sequence must be positive.',
      );
    }
    if (!operation.createdAtUtc.isUtc) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'createdAtUtc must use UTC.',
      );
    }
    if (operation.timestamp.deviceId != operation.sourceDeviceId) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'HLC device must match sourceDeviceId.',
      );
    }
    if (operation.timestamp.physicalMillisUtc < 0 ||
        operation.timestamp.logicalCounter < 0) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'HLC components must not be negative.',
      );
    }
    if (operation.causalCursor.sequenceFor(operation.sourceDeviceId) !=
        operation.sequence - 1) {
      throw const SyncProtocolException(
        SyncErrorCode.sequenceGap,
        'The source causal cursor must end immediately before the operation.',
      );
    }
    _operationShape(operation);
    _jsonValue(operation.payload, 0);
  }

  static void _versions(int protocolVersion, int schemaVersion) {
    if (protocolVersion != SyncProtocol.version) {
      throw const SyncProtocolException(
        SyncErrorCode.protocolIncompatible,
        'Unsupported sync protocol version.',
      );
    }
    if (schemaVersion != SyncProtocol.targetDatabaseSchemaVersion) {
      throw const SyncProtocolException(
        SyncErrorCode.schemaIncompatible,
        'Unsupported database schema version.',
      );
    }
  }

  static void _operationShape(SyncOperation operation) {
    final isRelation =
        operation.operationType == SyncOperationType.relationAdd ||
        operation.operationType == SyncOperationType.relationRemove;
    if (isRelation) {
      if (operation.entityType != SyncEntityType.todoTag ||
          operation.fieldGroup != SyncFieldGroup.tags) {
        throw const SyncProtocolException(
          SyncErrorCode.validationFailed,
          'Relation operations must target the todoTag tags group.',
        );
      }
      _identifier(_payloadString(operation, 'todoId'), 'payload.todoId');
      _identifier(_payloadString(operation, 'tagId'), 'payload.tagId');
      if (operation.operationType == SyncOperationType.relationRemove) {
        final observed = operation.payload['observedAddOperationIds'];
        if (observed is! List || observed.any((value) => value is! String)) {
          throw const SyncProtocolException(
            SyncErrorCode.validationFailed,
            'Relation removal must list observed add operation ids.',
          );
        }
        for (final operationId in observed.cast<String>()) {
          _identifier(operationId, 'payload.observedAddOperationIds');
        }
      }
      return;
    }
    if (operation.entityType == SyncEntityType.todoTag) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'todoTag requires a relation operation.',
      );
    }
    final allowedGroups = switch (operation.entityType) {
      SyncEntityType.todo => {
        SyncFieldGroup.content,
        SyncFieldGroup.completion,
        SyncFieldGroup.order,
        SyncFieldGroup.deletion,
      },
      SyncEntityType.category || SyncEntityType.tag => {
        SyncFieldGroup.content,
        SyncFieldGroup.order,
        SyncFieldGroup.deletion,
      },
      SyncEntityType.recurrenceSeries => {
        SyncFieldGroup.content,
        SyncFieldGroup.deletion,
      },
      SyncEntityType.recurrenceException => {
        SyncFieldGroup.content,
        SyncFieldGroup.completion,
        SyncFieldGroup.deletion,
      },
      SyncEntityType.todoTag => const <SyncFieldGroup>{},
    };
    if (!allowedGroups.contains(operation.fieldGroup)) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        '${operation.entityType.wireName} does not support '
        '${operation.fieldGroup.wireName}.',
      );
    }
    if ((operation.operationType == SyncOperationType.delete ||
            operation.operationType == SyncOperationType.restore) &&
        operation.fieldGroup != SyncFieldGroup.deletion) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Delete and restore operations must target the deletion group.',
      );
    }
    if (operation.operationType == SyncOperationType.upsert &&
        operation.fieldGroup == SyncFieldGroup.deletion) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Deletion state must use delete or restore.',
      );
    }
    if (operation.operationType == SyncOperationType.delete) {
      final deletedAt = operation.payload['deletedAt'];
      final parsed = deletedAt is String ? DateTime.tryParse(deletedAt) : null;
      if (parsed == null || !parsed.isUtc) {
        throw const SyncProtocolException(
          SyncErrorCode.validationFailed,
          'Delete payload requires a UTC deletedAt timestamp.',
        );
      }
    }
    if (operation.operationType == SyncOperationType.restore &&
        operation.payload['deletedAt'] != null) {
      throw const SyncProtocolException(
        SyncErrorCode.validationFailed,
        'Restore payload must set deletedAt to null.',
      );
    }
  }

  static String _payloadString(SyncOperation operation, String key) {
    final value = operation.payload[key];
    if (value is! String) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        'payload.$key must be a string.',
      );
    }
    return value;
  }

  static void _identifier(String value, String label) {
    if (value.trim().isEmpty ||
        value.length > SyncProtocol.maximumIdentifierLength) {
      throw SyncProtocolException(
        SyncErrorCode.validationFailed,
        '$label is blank or too long.',
      );
    }
  }

  static void _jsonValue(Object? value, int depth) {
    if (depth > SyncProtocol.maximumJsonDepth) {
      throw const SyncProtocolException(
        SyncErrorCode.payloadTooLarge,
        'JSON nesting is too deep.',
      );
    }
    switch (value) {
      case null || bool() || num():
        return;
      case String():
        if (value.length > SyncProtocol.maximumStringLength) {
          throw const SyncProtocolException(
            SyncErrorCode.payloadTooLarge,
            'A payload string exceeds the size limit.',
          );
        }
      case List():
        for (final child in value) {
          _jsonValue(child, depth + 1);
        }
      case Map():
        for (final entry in value.entries) {
          if (entry.key is! String) {
            throw const SyncProtocolException(
              SyncErrorCode.validationFailed,
              'JSON object keys must be strings.',
            );
          }
          _jsonValue(entry.value, depth + 1);
        }
      default:
        throw const SyncProtocolException(
          SyncErrorCode.validationFailed,
          'Payload contains a non-JSON value.',
        );
    }
  }
}

bool _mapEquals(Map<String, int> left, Map<String, int> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}
