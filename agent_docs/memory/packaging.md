---
note_type: durable-branch
area: packaging
updated: 2026-04-30
tags:
  - agent-knowledge
  - memory
  - packaging
update_when: >
  A new version is tagged and released to PyPI; the build backend or asset
  bundling config changes; a new top-level asset directory is added to the wheel.
  Check `git tag --list` and pyproject.toml for the source of truth.
---

# 📦 Packaging

Python [[stack|packaging]] strategy for making bedrock pip-installable.

## ⚙️ Build System

- Backend: **hatchling** via `pyproject.toml`
- Layout: src-layout at `src/agent_knowledge/`
- Entry points: `bedrock = agent_knowledge.cli:main`, `agent-knowledge = agent_knowledge.cli:main` (deprecated alias)

## 🗂️ Asset Bundling

All non-Python assets consolidated under `assets/` at repo root. Bundled into wheel via `[tool.hatch.build.targets.wheel.force-include]`:
- `assets/scripts` -> `agent_knowledge/assets/scripts`
- `assets/templates` -> `agent_knowledge/assets/templates`
- `assets/rules` -> `agent_knowledge/assets/rules`
- (and rules-global, commands, skills, skills-cursor, claude)

See [[architecture#Path Resolution]] for how the code finds these at runtime.

## 🏷️ Version

Current: **0.4.7** (tagged `v0.4.7`). PyPI package name: `project-bedrock`. See [[deployments]].

Install: `pip install project-bedrock` or `pipx install project-bedrock`. Command: `bedrock`.

**Breaking change in 0.4.0**: vault folder renamed from `./agent-knowledge/` to `./bedrock/`. Existing users run `bedrock migrate-vault` then `bedrock refresh-system`.

## 🚀 PyPI Publish

CI trusted publishing (OIDC) is currently broken — the PyPI trusted publisher config doesn't match the workflow. Publishing is done locally via twine from a temp venv:
```bash
python3 -m venv /tmp/build-venv && /tmp/build-venv/bin/pip install build twine
/tmp/build-venv/bin/python -m build && /tmp/build-venv/bin/twine upload dist/*
```
Fix: go to PyPI project settings → Publishing → update trusted publisher to match `publish.yml` (no environment field).

## 🧩 Dependencies

See [[stack#Dependencies]] for the full list.

## 🕓 Recent Changes

- 2026-04-28: Bumped to v0.2.9; `docs/` folder added to repo for GitHub/PyPI display assets (GIF, examples) — not included in wheel.
- 2026-04-28: Bumped to v0.3.0 — see deployments for full changelog.
- 2026-04-28: PyPI package renamed from `agent-knowledge-cli` to `project-bedrock` (v0.3.0).
- 2026-04-28: CLI primary command renamed from `agent-knowledge` to `bedrock`; `agent-knowledge` kept as deprecated alias (v0.3.1).
- 2026-04-28: `migrate-from-legacy` command added to help existing users migrate (v0.3.2). `pipx install project-bedrock` recommended for global install.
- 2026-04-29: v0.4.0 — vault folder renamed `agent-knowledge/` → `bedrock/` everywhere. `migrate-vault` command added for existing users. Windows compatibility fixes (bash detection, JSON paths, UTF-8 git output).
- 2026-04-30: v0.4.1 — `completion`, `upgrade`, `/compact-context` commands added. Specialist commands hidden from `--help`. CI tests fixed for v0.4.0 rename.
- 2026-05-05: v0.4.3 — wikilink JS regex fix (`\\.md` → `\.md`); README agent-first install flow.
- 2026-05-05: v0.4.4 — `encoding="utf-8"` added to all `read_text()`/`write_text()` calls across 8 modules (fixes Windows cp1255 crash).
- 2026-05-05: v0.4.5 — `.codex/AGENTS.md` template rewritten to be fully self-contained (no longer defers to root AGENTS.md).
- 2026-05-05: v0.4.6 — `install-global` command added; writes to `~/.cursor/rules/`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`.
- 2026-05-05: v0.4.7 — Gemini CLI + Antigravity support; `GEMINI.md` template; `~/.gemini/GEMINI.md` in `install-global`.

## 🔗 See Also

- [[stack]] -- runtimes and frameworks
- [[architecture]] -- package layout
- [[gotchas]] -- pip installation pitfalls
- [[decisions#001|Decision: hatchling over setuptools]]
