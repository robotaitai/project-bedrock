# agents-rules

Framework repo for agent rules, skills, templates, and operational scripts around adaptive project knowledge.

## Model

The v2 system uses three layers:

1. Global framework repo
   This repo. It owns shared commands, rules, skills, templates, and operational scripts.
2. Dedicated project knowledge folder
   The real source of truth for a project's memory. This should live outside the app repo.
3. Local project pointer
   `./agent-knowledge` inside the app repo. Tools inside the repo still read and write through this path, but it should resolve to the dedicated external folder.

All scripts, commands, hooks, and agent workflows operate through `./agent-knowledge` as the local handle. The external folder remains the source of truth, and this repo does not redesign the system into repo-local storage.

That means the project repo stays clean while agents still get a stable in-repo entrypoint.

## Knowledge Layout

```text
agent-knowledge/
  INDEX.md
  STATUS.md
  Memory/
    MEMORY.md
    decisions/
    tooling/
  Evidence/
    raw/
    imports/
      graphify/
    tooling/
  Sessions/
  Outputs/
    graphify/
  Dashboards/
  Templates/
  .obsidian/
```

Rules of thumb:

- `Memory/` is curated durable knowledge.
- `Evidence/` is raw or imported input, not canonical truth.
- `Sessions/` is temporary state.
- `Outputs/` stays in the external knowledge folder. It is not a repo export or snapshot channel.
- Machine-generated structural summaries, inferred relationships, and graph reports belong in `Evidence/` or `Outputs/` first, not in `Memory/`.
- `STATUS.md` is the lightweight operational state note for bootstrap, sync, compaction, validation, and doctor.

Confidence labels used across evidence and generated discovery notes:

- `EXTRACTED`: directly copied or listed from a source
- `INFERRED`: derived summary or architecture guess that still needs review
- `AMBIGUOUS`: incomplete, stale, or uncertain source material such as sessions or traces

## Install And Link

Connect a project to an external knowledge folder:

```bash
scripts/install-project-links.sh --slug my-project --repo /path/to/repo
```

Optional flags:

- `--knowledge-home <dir>` changes the default external root. Default: `~/agent-os/projects`
- `--real-path <dir>` uses an explicit knowledge folder instead of `<knowledge-home>/<slug>`
- `--install-hooks` installs a repo-local `.cursor/hooks.json` from the template
- `--dry-run` previews the setup without mutating files

The linking flow creates or verifies:

- external knowledge folder
- local `./agent-knowledge` pointer
- `.agent-project.yaml`
- `.agentknowledgeignore`
- `AGENTS.md`
- optional `.cursor/hooks.json`

The linking flow does not copy knowledge back into the repo and does not create a repo-local fallback vault.

## Core Commands

### Project Knowledge Sync

```bash
scripts/update-knowledge.sh --project /path/to/repo
```

What it does:

- bootstraps the memory tree if missing
- inspects changed repo files
- classifies touched knowledge branches
- appends durable recent-change entries when needed
- refreshes evidence imports
- updates `agent-knowledge/STATUS.md`

It always writes through `./agent-knowledge`, which should resolve to the external source-of-truth folder.

### Global Tooling Sync

```bash
scripts/global-knowledge-sync.sh --project /path/to/repo
```

What it does:

- scans safe allowlisted local tool surfaces
- redacts sensitive lines before writing evidence
- writes tooling evidence under `Evidence/tooling/`
- writes curated tooling summaries under `Memory/tooling/`
- skips session/auth/cache surfaces

It writes into the same external knowledge vault through the local `./agent-knowledge` handle.

This is different from project knowledge sync:

- project sync is about repo changes and project memory
- global tooling sync is about safe user-level tool configuration that can affect work across projects

### Optional Graph Sync

```bash
scripts/graphify-sync.sh --project /path/to/repo
```

What it does:

- looks for optional graph/discovery export artifacts such as `graphify` outputs
- imports them under `Evidence/imports/graphify/`
- generates non-canonical summaries under `Outputs/graphify/`
- keeps graph structure as evidence first instead of promoting it into `Memory/`

This flow is optional. Missing graph tooling does not fail the knowledge system.

### Ship

```bash
scripts/ship.sh --project /path/to/repo
```

What it does:

- checks git state
- runs detected repo validations
- runs knowledge sync and compaction
- stages repo-local changes
- commits and pushes when possible
- optionally opens a PR

If the real knowledge vault lives outside the repo, ship reports that explicitly instead of pretending those external files were committed.
It does not snapshot the external knowledge vault back into the repo.

### Validation And Doctor

```bash
scripts/validate-knowledge.sh --project /path/to/repo
scripts/doctor.sh --project /path/to/repo
```

`validate-knowledge.sh` checks:

- required folders and files
- durable note frontmatter and required sections
- obvious broken relative links
- `.agent-project.yaml` presence and key fields
- pointer resolution
- required scripts, commands, and rules

`doctor.sh` is the short troubleshooting entrypoint. It runs validation and surfaces setup warnings such as hook installation or pointer-mode drift.

## Dry-Run And Idempotency

Operational scripts are designed to be safe and reviewable:

- write-oriented scripts support `--dry-run`
- reruns are intended to be idempotent
- file writes go through compare-before-replace helpers
- scripts fail fast on broken setup instead of mutating partial state
- canonical mode requires `./agent-knowledge` to resolve to the external knowledge folder
- import-oriented scripts use lightweight cache signatures where practical so unchanged evidence sources can be skipped

Current write-oriented scripts with `--dry-run` support:

- `scripts/install-project-links.sh`
- `scripts/bootstrap-memory-tree.sh`
- `scripts/import-agent-history.sh`
- `scripts/update-knowledge.sh`
- `scripts/global-knowledge-sync.sh`
- `scripts/graphify-sync.sh`
- `scripts/compact-memory.sh`
- `scripts/ship.sh`

## Ignore Controls

Use `.agentknowledgeignore` in the project repo to exclude noisy paths from evidence and structural discovery imports.

- history import respects it for repo structure, docs, config files, task files, traces, and similar project-local sources
- graph sync respects it for project-local graph/discovery artifact paths
- global tooling sync does not use it because those sources come from an explicit allowlist outside the repo

## Hooks

Hook support is template-driven.

- template: `templates/hooks/hooks.json.template`
- optional install path: `.cursor/hooks.json`

The hook should call the shared project sync primitive, not reimplement logic:

```json
{
  "hooks": [
    {
      "name": "project-knowledge-sync",
      "event": "post-write",
      "command": "/path/to/agents-rules/scripts/update-knowledge.sh --summary-file /path/to/repo/.cursor/knowledge-sync.last.json /path/to/repo"
    }
  ]
}
```

Keep hooks lightweight, inspectable, and easy to disable.

## Scripts

- `scripts/install-project-links.sh`: connect a repo to the external knowledge folder and optional hooks
- `scripts/bootstrap-memory-tree.sh`: initialize or repair the knowledge tree scaffold
- `scripts/import-agent-history.sh`: refresh raw and imported evidence only
- `scripts/graphify-sync.sh`: optional graph/discovery import into evidence and outputs
- `scripts/update-knowledge.sh`: main project knowledge sync primitive
- `scripts/global-knowledge-sync.sh`: safe tooling sync into project-local tooling memory/evidence
- `scripts/compact-memory.sh`: compact noisy recent-change sections
- `scripts/validate-knowledge.sh`: structural validator for the knowledge system
- `scripts/doctor.sh`: quick troubleshooting summary
- `scripts/ship.sh`: validate, sync, commit, push, optional PR
- `scripts/measure-token-savings.py`: placeholder analysis helper

## OS Caveats

- macOS may resolve `/tmp` to `/private/tmp`; the scripts normalize real knowledge paths to avoid false pointer mismatches.
- Windows-style environments may require Developer Mode or elevated permissions for symlinks. The install script reports this caveat, and a junction may be needed if symlink creation is blocked.

## Philosophy

The repo still keeps the original philosophy:

- file-based, not database-backed
- explicit evidence versus memory separation
- durable notes stay readable in plain markdown
- Obsidian-compatible by default
- operational scripts stay small and shared logic stays centralized
