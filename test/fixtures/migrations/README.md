# Immutable migration baselines

These public Drift schema snapshots are immutable inputs for future migration tests:

| App schema | Snapshot | SHA-256 |
| --- | --- | --- |
| v1 | `drift_schemas/app_database/drift_schema_v1.json` | `669db0514ec8898bbe690d3add460c27c513320ae0d7715ba55e7d4c97507926` |
| v2 | `drift_schemas/app_database/drift_schema_v2.json` | `3e4c5d8e86039710be487187d6d9e1d46c9e60e8cda808e522af0a0ce701d1b2` |
| v3 | `drift_schemas/app_database/drift_schema_v3.json` | `7354d87ff0f312732c900e4ffb62b5ee25aa031d50ec31ea0638b9845bd3f2d7` |

Representative data seeds are immutable too:

| App schema | Seed | SHA-256 |
| --- | --- | --- |
| v1 | `test/fixtures/migrations/schema_v1_seed.sql` | `06cc800522455f7cdf554f6c6eb14ec74b37424bafe0e4dd4affbbd982fb8bc3` |
| v2 | `test/fixtures/migrations/schema_v2_seed.sql` | `23a090f7f48a9c3c16efd2535ce0cbcde2e2365978b01160c14dcd58e6dddd25` |
| v3 | `test/fixtures/migrations/schema_v3_seed.sql` | `6b4787eadca3c0f205fdd593d4aefc8f099a866b0d14c3a5a9e4c3845050c7ca` |

Never regenerate or edit a published snapshot or seed in place. Add a new snapshot, seed, checksum, and migration case for every future public schema.

`schema_baseline_test.dart` verifies these hashes so accidental changes fail CI before migration behavior can silently drift.
