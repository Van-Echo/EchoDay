-- Immutable representative data for a public EchoDay schema v4 database.
PRAGMA foreign_keys = ON;
INSERT INTO todos (id, title, local_date, is_completed, is_abandoned, created_at, updated_at, planned_at, priority, category_id, notes, deadline_at, time_zone_id, completed_at, abandoned_at, deleted_at, manual_order, revision, recurrence_series_id, occurrence_date)
VALUES ('fixture-abandoned-todo', 'Verify schema v4', '2026-10-06', 0, 1, 1791255600000, 1791259200000, NULL, 3, NULL, 'v4 abandonment fixture', NULL, 'Asia/Shanghai', NULL, 1791259200000, NULL, 1.0, 2, NULL, NULL);
INSERT INTO settings (key, value, updated_at, revision)
VALUES ('appearance.themeMode', 'light', 1791259200000, 1);
PRAGMA user_version = 4;
