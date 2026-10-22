-- Immutable representative data for EchoDay schema v5 (future inbox).
PRAGMA foreign_keys = ON;
INSERT INTO todos (id, title, local_date, is_completed, is_abandoned, is_future, created_at, updated_at, priority, manual_order, revision)
VALUES ('fixture-future-todo', 'An unscheduled idea', '2026-10-22', 0, 0, 1, 1792641600000, 1792641600000, 3, 1.0, 1);
INSERT INTO settings (key, value, updated_at, revision)
VALUES ('appearance.themeMode', 'light', 1792641600000, 1);
PRAGMA user_version = 5;
