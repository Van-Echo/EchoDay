-- Immutable representative data for a public EchoDay schema v1 database.
PRAGMA foreign_keys = ON;
INSERT INTO categories (id, name, color_value, sort_order, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-category', '工作', 4286098551, 1.0, 1788915600000, 1788915600000, NULL, 2);
INSERT INTO tags (id, name, color_value, sort_order, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-tag', '开发', 4284907148, 1.0, 1788915600000, 1788915600000, NULL, 2);
INSERT INTO recurrence_series (id, start_date, rule_json, time_zone_id, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-series', '2026-09-09', '{"frequency":"daily","interval":1}', 'Asia/Shanghai', 1788915600000, 1788915600000, NULL, 1);
INSERT INTO todos (id, title, local_date, is_completed, created_at, updated_at, planned_at, priority, category_id, notes, deadline_at, time_zone_id, completed_at, deleted_at, manual_order, revision, recurrence_series_id, occurrence_date)
VALUES ('fixture-todo', '完成同步基线', '2026-09-09', 0, 1788915600000, 1788915600000, 1788922800000, 1, 'fixture-category', 'v1 migration fixture', 1788951600000, 'Asia/Shanghai', NULL, NULL, 2.0, 3, 'fixture-series', '2026-09-09');
INSERT INTO todo_tags (todo_id, tag_id) VALUES ('fixture-todo', 'fixture-tag');
INSERT INTO recurrence_exceptions (id, series_id, occurrence_date, override_json, is_skipped, created_at, updated_at, deleted_at, revision)
VALUES ('fixture-exception', 'fixture-series', '2026-09-10', NULL, 1, 1788915600000, 1788915600000, NULL, 1);
INSERT INTO holiday_years (year, source_url, data_version, checksum, payload_json, updated_at)
VALUES (2026, 'https://example.invalid/fixture', 'fixture-v1', 'fixture', '{}', 1788915600000);
INSERT INTO settings (key, value, updated_at, revision)
VALUES ('appearance.themeMode', 'dark', 1788915600000, 2);
PRAGMA user_version = 1;
