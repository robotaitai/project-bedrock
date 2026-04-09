---
area: architecture
updated: 2026-04-08
---

# Architecture

## Purpose
Core design patterns: path resolution, project config, template system, integrations, onboarding.

## Current State

### Path resolution
- `runtime/paths.py` provides `get_assets_dir()` with dual-mode resolution:
  1. Installed package: `assets/` is sibling of `runtime/` inside `site-packages/agent_knowledge/`.
  2. Dev checkout: falls back to `repo_root/assets/` (4 parent levels up from `runtime/paths.py`, then into `assets/`).
- Marker file for validation: `scripts/lib/knowledge-common.sh`.
- Result is cached in `_cached_assets_dir` for the process lifetime.
- All shell scripts derive `AGENTS_RULES_DIR` from their own `SCRIPT_DIR` (one level up from `scripts/`), making them location-independent regardless of installed vs dev.

### Asset consolidation
- All non-Python assets live under a single top-level `assets/` directory (scripts, templates, rules, rules-global, commands, skills, skills-cursor, claude).
- Old root-level directories (scripts/, commands/, rules/, templates/, etc.) were deleted after moving into `assets/`.

### Project config (.agent-project.yaml)
- Version 4, ontology_model 2.
- No `framework.repo` field. Scripts find assets via SCRIPT_DIR.
- `profile_hint` (was `profile`): weak hint for the agent, not a required schema.
- Added `onboarding: status: pending` field to track first-time setup state.
- `hooks.project_sync_command` and `hooks.graph_sync_command` reference CLI commands (`agent-knowledge update --project .`).
- No `root_index` key -- INDEX.md files have been removed in favor of STATUS.md + MEMORY.md as entry points.

### Integration system (runtime/integrations.py)
- `detect(repo_path)` checks for `.cursor/`, `.claude/`, `.codex/` directories to identify which tools are present. Always returns True for Cursor (should always be installed).
- `install_all(repo_path, detected, ...)` installs bridge files for all detected tools.
- Cursor: `.cursor/hooks.json` (from template) + `.cursor/rules/agent-knowledge.mdc` (content inlined in Python as `_CURSOR_RULE` constant -- workaround for pip extraction bug with `.mdc` files).
- Claude: `CLAUDE.md` at project root (from template).
- Codex: `.codex/AGENTS.md` (from template).
- `doctor.sh` detects and reports integrations in both JSON and human output.

### Onboarding state
- `STATUS.md` tracks `onboarding: pending|complete` in YAML frontmatter.
- `knowledge-common.sh` loads/writes `STATUS_ONBOARDING` variable.
- `AGENTS.md` instructs agents to check STATUS.md and perform first-time ingestion if `onboarding: pending`.
- Tool-specific bridge files (Cursor rule, CLAUDE.md, .codex/AGENTS.md) reinforce this by directing agents to read STATUS.md on session start.

### Hooks template
- `.cursor/hooks.json` template moved to `assets/templates/integrations/cursor/hooks.json`.
- Uses `agent-knowledge update --summary-file <path> --project <path>`.

### Global install
- Root `install.sh` deleted. Replaced by `agent-knowledge setup` CLI command (pure Python).
- Symlinks rules and skills from the repo checkout into `~/.cursor/rules/` and `~/.cursor/skills/`.
- Calls `claude/scripts/install.sh` for Claude Code global rules.

## Recent Changes

- 2026-04-09: Ontology model v2: replaced profile-defined INDEX.md tree with agent-inferred same-name branch convention.
- 2026-04-09: Deleted all INDEX.md templates; renamed `area.template.md` to `branch.template.md`.
- 2026-04-09: Profiles weakened to hints (`candidate_areas` + `signals`), no longer drive file creation.
- 2026-04-09: Bootstrap creates minimal scaffold only; agent infers branches from repo.
- 2026-04-09: STATUS.md now uses `profile_hint` and `ontology_model: 2`.
- 2026-04-08: Consolidated all asset directories under `assets/`.
- 2026-04-08: Created `runtime/integrations.py` for multi-tool detection and bridge file installation.

## Gotchas

- `install-project-links.sh` had a `set -euo pipefail` + trailing `[ "$DRY_RUN" -eq 1 ] && log ...` pattern that caused exit 1 when DRY_RUN=0 because the `[` test returned false. Fixed with explicit `if`.
- `ship.sh` must use `python -m pytest -q` (not bare `pytest`) to work outside venvs where pytest isn't on PATH.
- Error messages in `bootstrap-memory-tree.sh` and `update-knowledge.sh` must say "Run: agent-knowledge init" (not the old "--slug <slug> --repo ." form).

## Open Questions

- None currently.
