---
note_type: durable-branch
area: history-layer
updated: 2026-05-17
tags:
  - agent-knowledge
  - memory
  - history
update_when: >
  A new event type is added; the deduplication rules change; new commands
  interact with History/; the file structure under History/ changes.
---

# 📅 History Layer

Lightweight project diary. Records what happened over time without becoming a second knowledge base.

## 🗂️ Structure

```
History/
  events.ndjson    -- append-only machine-readable event log (NDJSON)
  history.md       -- human-readable entrypoint (< 150 lines, auto-generated)
  timeline/        -- sparse milestone notes (init, backfill, releases only)
```

## 🔀 Memory vs History

| Layer | Role |
|-------|------|
| `Memory/` | What is true now (curated, authoritative) |
| `History/` | What happened over time (lightweight diary) |
| `Evidence/` | Imported/extracted material (non-canonical) |
| `Views/` | Generated human inspection artifacts |
| `Outputs/` | Legacy generated artifacts kept only for compatibility |
| `Sessions/` | Temporary working state |

History is **not** a git replacement, not a full transcript store, not a second source of truth.

## 📋 Event Types

- `project_start` — first git commit date + total commits (once ever)
- `release` — one event per git tag (deduplicated by tag name)
- `integration_cursor/claude/codex` — detected tool integration (once per month)
- `backfill` — summary of the backfill run (once per month)

History intentionally records milestones and chronology, not every routine sync.

## 🔁 Deduplication

- `project_start`: once ever
- `release`: once per tag name
- `backfill`, `integration_*`: once per calendar month
- Safe to re-run: idempotent by design

## 🛠️ Commands

- `bedrock init` — auto-backfills history after setup
- `bedrock backfill-history` — manual refresh, supports `--dry-run`, `--json`, `--force`
- `bedrock doctor` — warns if `History/` is missing

## 🔄 Consolidation Notes

- The active `bedrock/History/` now contains the older backfill notes that originally lived only in the legacy `agent-knowledge/` vault.
- This keeps long-range project history accessible in one place while the active cockpit stays small elsewhere.

## ⚙️ Implementation

- `src/agent_knowledge/runtime/history.py`
- Functions: `run_backfill()`, `init_history()`, `append_event()`, `log_event()`, `read_events()`, `history_exists()`
- Git helpers: subprocess calls to `git log`, `git tag`, `git rev-list`

## 🕓 Recent Changes

- 2026-05-17: Older backfill notes from the legacy `agent-knowledge/` vault were copied into the active `bedrock/History/` tree so historical context is preserved during cleanup.
- 2026-05-17: The active vault cleanup clarified that routine syncs do not belong in History or as per-sync capture files; History remains focused on releases, integrations, and backfills.

## 🔗 See Also

- [[architecture]] -- runtime module layout
- [[cli]] -- backfill-history and doctor commands
