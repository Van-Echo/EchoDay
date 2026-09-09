-- Immutable representative data for a public EchoDay schema v3 database.
PRAGMA foreign_keys = ON;
INSERT INTO categories (id, name, color_value, sort_order, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-category', 'Life', 4286098551, 1.0, 1788915600000, 1788919200000, NULL, 3);
INSERT INTO tags (id, name, color_value, sort_order, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-tag', 'Plan', 4284907148, 1.0, 1788915600000, 1788919200000, NULL, 3);
INSERT INTO recurrence_series (id, start_date, rule_json, time_zone_id, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-series', '2026-09-09', '{"frequency":"weekly","interval":1}', 'Asia/Shanghai', 1788915600000, 1788919200000, NULL, 2);
INSERT INTO todos (id, title, local_date, is_completed, created_at, updated_at, planned_at, priority, category_id, notes, deadline_at, time_zone_id, completed_at, deleted_at, manual_order, revision, recurrence_series_id, occurrence_date)
VALUES ('fixture-todo', 'Verify schema v3', '2026-09-09', 1, 1788915600000, 1788919200000, 1788922800000, 2, 'fixture-category', 'v3 migration fixture', 1788951600000, 'Asia/Shanghai', 1788919200000, NULL, 4.0, 4, 'fixture-series', '2026-09-09');
INSERT INTO todo_tags (todo_id, tag_id) VALUES ('fixture-todo', 'fixture-tag');
INSERT INTO recurrence_exceptions (id, series_id, occurrence_date, override_json, is_skipped, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-exception', 'fixture-series', '2026-09-16', '{"notes":"exception"}', 0, 1788915600000, 1788919200000, NULL, 2);
INSERT INTO holiday_years (year, source_url, data_version, checksum, payload_json, updated_at)
VALUES (2026, 'https://example.invalid/fixture', 'fixture-v3', 'fixture', '{}', 1788919200000);
INSERT INTO settings (key, value, updated_at, revision)
VALUES ('appearance.themeMode', 'light', 1788919200000, 3);
INSERT INTO sync_groups (id, role, host_device_id, protocol_version, is_active, created_at, updated_at)
VALUES ('fixture-group', 'host', 'fixture-device', 1, 1, 1788915600000, 1788919200000);
INSERT INTO sync_devices (device_id, sync_group_id, display_name, note, platform, app_version, protocol_version, public_key, created_at, updated_at, last_seen_at, revoked_at)
VALUES ('fixture-device', 'fixture-group', 'Fixture PC', NULL, 'windows', '1.0.0', 1, 'fixture-public-key', 1788915600000, 1788919200000, NULL, NULL);
INSERT INTO sync_pairing_invites (id, sync_group_id, token_hash, host_fingerprint, expires_at, attempt_count, maximum_attempts, created_at, consumed_at)
VALUES ('fixture-invite', 'fixture-group', 'fixture-token-hash', 'fixture-fingerprint', 1789002000000, 0, 5, 1788915600000, NULL);
INSERT INTO sync_changes (operation_id, sync_group_id, source_device_id, sequence, transaction_id, entity_type, entity_id, operation_type, field_group, payload_format_version, payload_json, hlc_physical_ms, hlc_logical, hlc_device_id, causal_cursor_json, created_at, applied_at)
VALUES ('fixture-operation', 'fixture-group', 'fixture-device', 1, 'fixture-transaction', 'todo', 'fixture-todo', 'upsert', 'content', 1, '{"title":"Verify schema v3"}', 1788919200000, 0, 'fixture-device', '{"fixture-device":0}', 1788919200000, 1788919200000);
INSERT INTO sync_entity_versions (sync_group_id, entity_type, entity_id, field_group, winning_operation_id, hlc_physical_ms, hlc_logical, hlc_device_id, causal_cursor_json, updated_at)
VALUES ('fixture-group', 'todo', 'fixture-todo', 'content', 'fixture-operation', 1788919200000, 0, 'fixture-device', '{"fixture-device":0}', 1788919200000);
INSERT INTO sync_relation_dots (sync_group_id, todo_id, tag_id, add_operation_id, added_by_device_id, added_sequence, removed_by_operation_id, created_at, removed_at)
VALUES ('fixture-group', 'fixture-todo', 'fixture-tag', 'fixture-relation-add', 'fixture-device', 2, NULL, 1788919200000, NULL);
INSERT INTO sync_cursors (sync_group_id, peer_device_id, source_device_id, acknowledged_sequence, updated_at)
VALUES ('fixture-group', 'fixture-device', 'fixture-device', 1, 1788919200000);
INSERT INTO sync_conflicts (id, sync_group_id, entity_type, entity_id, field_group, kind, winner_operation_id, loser_operation_id, losing_payload_json, created_at, resolved_at, resolution_operation_id)
VALUES ('fixture-conflict', 'fixture-group', 'todo', 'fixture-todo', 'content', 'concurrentFieldEdit', 'fixture-operation', 'fixture-loser', '{"title":"Old title"}', 1788919200000, NULL, NULL);
INSERT INTO sync_runtime_states (key, value, updated_at)
VALUES ('sync.localDeviceId', 'fixture-device', 1788919200000);
PRAGMA user_version = 3;
