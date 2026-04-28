---
note_type: durable-branch
area: packaging
updated: 2026-04-28
tags:
  - agent-knowledge
  - memory
  - packaging
update_when: >
  A new version is tagged and released to PyPI; the build backend or asset
  bundling config changes; a new top-level asset directory is added to the wheel.
  Check `git tag --list` and pyproject.toml for the source of truth.
---

# Packaging

Python [[stack|packaging]] strategy for making bedrock pip-installable.

## Build System

- Backend: **hatchling** via `pyproject.toml`
- Layout: src-layout at `src/agent_knowledge/`
- Entry points: `bedrock = agent_knowledge.cli:main`, `agent-knowledge = agent_knowledge.cli:main` (deprecated alias)

## Asset Bundling

All non-Python assets consolidated under `assets/` at repo root. Bundled into wheel via `[tool.hatch.build.targets.wheel.force-include]`:
- `assets/scripts` -> `agent_knowledge/assets/scripts`
- `assets/templates` -> `agent_knowledge/assets/templates`
- `assets/rules` -> `agent_knowledge/assets/rules`
- (and rules-global, commands, skills, skills-cursor, claude)

See [[architecture#Path Resolution]] for how the code finds these at runtime.

## Version

Current: **0.3.0** (tagged `v0.3.0`). PyPI package name: `project-bedrock`. See [[deployments]].

Install: `pip install project-bedrock`. Command: `bedrock`.

## Dependencies

See [[stack#Dependencies]] for the full list.

## Recent Changes

- 2026-04-28: Bumped to v0.2.9; `docs/` folder added to repo for GitHub/PyPI display assets (GIF, examples) — not included in wheel.
- 2026-04-28: Bumped to v0.3.0 — see deployments for full changelog.

## See Also

- [[stack]] -- runtimes and frameworks
- [[architecture]] -- package layout
- [[gotchas]] -- pip installation pitfalls
- [[decisions#001|Decision: hatchling over setuptools]]
