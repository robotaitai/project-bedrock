---
note_type: durable-branch
area: cli
updated: 2026-04-28
tags:
  - agent-knowledge
  - cli
update_when: >
  A command is added, removed, or renamed; a command's delegation target changes
  (shell script → pure Python or vice-versa); a significant flag is added to an
  existing command. Run `bedrock --help` and diff against the table below.
---

# CLI

Design and implementation of the `bedrock` command-line interface.

## Framework

Built on [[stack|click >= 8.0]] with a `@click.group()` top-level.

## Subcommands (23)

| Command | Description | Delegates to |
|---------|-------------|-------------|
| `init` | Zero-arg project setup + history backfill. Local (in-repo) by default; `--external` for external vault | `install-project-links.sh` + integrations + history.py |
| `migrate-to-local` | Convert existing external-vault project: copy vault, swap pointer, patch .gitignore | pure Python |
| `sync` | Memory sync, git evidence extraction, update STATUS.md | `runtime/sync.py` |
| `setup` | Global Cursor rules/skills install | pure Python |
| `bootstrap` | Repair memory tree | `bootstrap-memory-tree.sh` |
| `import` | Import repo evidence | `import-agent-history.sh` |
| `update` | Sync project changes | `update-knowledge.sh` |
| `doctor` | Validate setup, staleness warnings | `doctor.sh` + Python pre-checks |
| `validate` | Validate knowledge layout | `validate-knowledge.sh` |
| `ship` | Validate, sync, commit, push | `ship.sh` |
| `global-sync` | Import global tooling config | `global-knowledge-sync.sh` |
| `graphify-sync` | Import graph artifacts | `graphify-sync.sh` |
| `compact` | Prune stale memory and old captures | `compact-memory.sh` |
| `measure-tokens` | Token savings estimation (subcommands: compare, log-run, summarize-log) | `measure-token-savings.py` |
| `index` | Regenerate knowledge index JSON + md | `runtime/index.py` |
| `search <query>` | Search knowledge index, Memory-first | `runtime/index.py` |
| `export-html` | Build polished static HTML site | `runtime/site.py` |
| `view` | Build site and open in browser | `runtime/site.py` + webbrowser |
| `clean-import <url>` | Import URL/HTML as cleaned evidence | `runtime/capture.py` |
| `export-canvas` | Export vault as Obsidian Canvas | `runtime/site.py` |
| `absorb` | Ingest existing project docs into Evidence/imports/, parse ADRs into decisions.md | pure Python |
| `refresh-system` | Refresh integration files to current framework version | `runtime/refresh.py` |
| `backfill-history` | Backfill lightweight history from git | `runtime/history.py` |

## init

- Infers slug from directory name, detects integrations automatically
- **Default (local mode)**: creates `./agent-knowledge/` as real directory; creates `~/agent-os/projects/<slug>/` as symlink back; patches `.gitignore` with noisy-subfolder exclusions
- `--external` flag: creates knowledge in `~/agent-os/projects/<slug>/`; `./agent-knowledge` becomes a symlink to that folder
- `--local` flag: accepted as a no-op for backward compatibility (was previously needed, now the default)
- After setup: **auto-calls `run_backfill()`** from `history.py` if vault exists
- Prints cyan-bordered prompt with next-step suggestion

## migrate-to-local

- Detects current external vault from symlink
- `shutil.copytree` to temp dir → unlink symlink → move to real `./agent-knowledge/`
- Creates reversed symlink at `~/agent-os/projects/<slug>/` (skips if already a real dir)
- Updates `.agent-project.yaml` vault_mode + real_path via regex
- Calls `_patch_gitignore_for_local_knowledge()` — sentinel-guarded, idempotent

## absorb

- Scans project for docs: `ARCHITECTURE.md`, `CHANGELOG.md`, `DESIGN.md`, ADRs, etc.
- Copies to `Evidence/imports/` as non-canonical evidence
- Parses ADR/decision files into `decisions.md` (skippable via `--no-decisions`)
- Writes `Outputs/absorb-manifest.md` for agent review and curation
- Mechanical ingestion only — curation to `Memory/` remains the agent's responsibility

## doctor

- Calls `doctor.sh` (bash)
- **Python pre-check 1**: `refresh.is_stale()` — warns if framework version is behind
- **Python pre-check 2**: cursor + claude integration health checks
- **Python pre-check 3**: `history.history_exists()` — warns if History/ missing
- **Python pre-check 4**: `refresh.check_stale_notes()` — compares each durable-branch note's `updated` date against the most recent git commit on its watched source paths; warns with note path, dates, and `update_when` hint if source changed after the note was last updated

## refresh-system

- Refreshes `AGENTS.md`, `.cursor/hooks.json`, `.cursor/rules/agent-knowledge.mdc`, `CLAUDE.md`, `.codex/AGENTS.md`, `STATUS.md`, `.agent-project.yaml`
- Idempotent: returns "up-to-date" if version already matches
- Never touches `Memory/`, `Evidence/`, `Sessions/`, `Outputs/`, `History/`
- Supports `--dry-run`, `--json`

## backfill-history

- Creates `History/events.ndjson`, `History/history.md`, `History/timeline/`
- Reads git: first commit date, total commits, tags (releases), integration detection
- One-per-tag for release events; once-per-month for backfill/integration events
- Supports `--dry-run`, `--json`, `--force`

## export-html / view

- Reads vault → builds `knowledge.json` → builds `graph.json` → renders `index.html`
- All data embedded in HTML (no AJAX, works via `file://`)
- Views: Overview, Tree/Ontology, Note detail, Evidence, Graph tab
- Graph: interactive force-directed canvas, wikilink edges rendered in accent blue, searchable, filterable by type/canonical status
- `view` = `export-html` + opens result in browser

## Patterns

- Thin Python wrappers delegate to shell scripts via `subprocess` for legacy commands
- Pure-Python for newer commands: sync, site, history, refresh, capture, index, absorb
- Common flags: `--dry-run`, `--json`, `--force`
- All output to stderr in human mode; stdout is pure JSON in `--json` mode

## Recent Changes

- 2026-04-28: `init` now defaults to local (in-repo) mode; `--external` flag added to opt out.
- 2026-04-28: `doctor` now runs Python pre-checks for staleness — compares note `updated` dates against source code commit dates.
- 2026-04-28: `absorb` subcommand added (imports external docs/ADRs into Evidence/).

## See Also

- [[architecture]] -- runtime modules
- [[stack]] -- click framework, dependencies
- [[testing]] -- CLI test coverage
