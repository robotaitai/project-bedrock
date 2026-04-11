---
note_type: durable-branch
area: cli
updated: 2026-04-12
tags:
  - agent-knowledge
  - cli
---

# CLI

Design and implementation of the `agent-knowledge` command-line interface.

## Framework

Built on [[stack|click >= 8.0]] with a `@click.group()` top-level.

## Subcommands (21)

| Command | Description | Delegates to |
|---------|-------------|-------------|
| `init` | Zero-arg project setup + history backfill | `install-project-links.sh` + integrations + history.py |
| `sync` | Memory sync, session rollup, git evidence, capture, index | `runtime/sync.py` |
| `setup` | Global Cursor rules/skills install | pure Python |
| `bootstrap` | Repair memory tree | `bootstrap-memory-tree.sh` |
| `import` | Import repo evidence | `import-agent-history.sh` |
| `update` | Sync project changes | `update-knowledge.sh` |
| `doctor` | Validate setup, staleness warnings | `doctor.sh` + Python checks |
| `validate` | Validate knowledge layout | `validate-knowledge.sh` |
| `ship` | Validate, sync, commit, push | `ship.sh` |
| `global-sync` | Import global tooling config | `global-knowledge-sync.sh` |
| `graphify-sync` | Import graph artifacts | `graphify-sync.sh` |
| `compact` | Prune stale memory and old captures | `compact-memory.sh` |
| `measure-tokens` | Token savings estimation | `measure-token-savings.py` |
| `index` | Regenerate knowledge index JSON + md | `runtime/index.py` |
| `search <query>` | Search knowledge index, Memory-first | `runtime/index.py` |
| `export-html` | Build polished static HTML site | `runtime/site.py` |
| `view` | Build site and open in browser | `runtime/site.py` + webbrowser |
| `clean-import <url>` | Import URL/HTML as cleaned evidence | `runtime/capture.py` |
| `export-canvas` | Export vault as Obsidian Canvas | `runtime/site.py` |
| `refresh-system` | Refresh integration files to current framework version | `runtime/refresh.py` |
| `backfill-history` | Backfill lightweight history from git | `runtime/history.py` |

## init (zero-arg)

- Infers slug from directory name, detects integrations automatically
- Auto-runs `import-agent-history.sh` (no manual step needed)
- Auto-calls `run_backfill()` from `history.py` if vault exists
- **Final output**: single cyan box — "Paste in your agent chat: ..." (no noisy "Next steps" list)
- Bootstrap and install scripts no longer print their own "Next steps" sections

## doctor

- Calls `doctor.sh` (bash)
- **Python pre-check 1**: `refresh.is_stale()` — warns if framework version is behind
- **Python pre-check 2**: `refresh.check_cursor_integration()` — warns if rule/hooks/commands missing or incomplete
- **Python pre-check 3**: `history.history_exists()` — warns if History/ missing

## refresh-system

- Refreshes `AGENTS.md`, `.cursor/hooks.json`, `.cursor/rules/agent-knowledge.mdc`, `.cursor/commands/`, `CLAUDE.md`, `.codex/AGENTS.md`, `STATUS.md`, `.agent-project.yaml`
- Creates missing command files (memory-update.md, system-update.md) if commands/ dir absent
- Idempotent: returns "up-to-date" if version already matches
- Never touches `Memory/`, `Evidence/`, `Sessions/`, `Outputs/`, `History/`
- Supports `--dry-run`, `--json`

## backfill-history

- Creates `History/events.ndjson`, `History/history.md`, `History/timeline/`
- Reads git: first commit date, total commits, tags (releases), integration detection
- One-per-tag for release events; once-per-month for backfill/integration events
- Supports `--dry-run`, `--json`, `--force`

## export-html

- Reads vault → builds `knowledge.json` → builds `graph.json` → renders `index.html`
- All data embedded in HTML (no AJAX, works via file://)
- Views: Overview, Tree/Ontology, Note/detail, Evidence, Graph tab
- Graph: interactive force-directed canvas, searchable, filterable by type/canonical status
- Canonical (Memory) vs non-canonical (Evidence, Outputs) clearly badged

## Patterns

- Thin Python wrappers delegate to shell scripts via `subprocess`
- Pure-Python commands for new features (site, history, refresh, capture, index)
- Common flags: `--dry-run`, `--json`, `--force`
- All output to stderr in human mode; stdout is pure JSON in `--json` mode

## See Also

- [[architecture]] -- runtime modules
- [[stack]] -- click framework, dependencies
- [[testing]] -- CLI test coverage
