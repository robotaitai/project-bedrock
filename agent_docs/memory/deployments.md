---
note_type: durable-branch
area: deployments
updated: 2026-04-28
tags:
  - agent-knowledge
  - memory
  - deployments
update_when: >
  A new version is tagged and released; the CI matrix changes; the PyPI
  publication process changes; new release steps are added.
  Check `git tag --list` for the latest tag.
---

# 🚀 Deployments

Release, CI, and distribution strategy.

## 🏷️ Version

**0.3.2** (tagged `v0.3.2`). See [[packaging]].

## 🔁 CI Pipeline

[[testing|GitHub Actions]] (`.github/workflows/ci.yml`):
- Triggered on push/PR to `main`
- Matrix: `ubuntu-latest` + `macos-latest`, Python 3.10/3.12/3.13
- **test** job: pytest with editable install
- **build** job: wheel build + installed [[cli|CLI]] smoke test

## 📦 Distribution

- `pip install project-bedrock` (published to PyPI)
- Build: `python -m build` produces wheel and sdist
- Local dev: `pip install -e ".[dev]"` inside a venv (see [[gotchas]])

## 🚫 No Server Components

No Docker, no container deployment, no API server. See [[stack]].

## 🕓 Recent Changes

- 2026-04-28: Released v0.3.0 — table rendering, graph neighbor highlight, local-mode default, staleness detection, absorb command, graph spread tuning.
- 2026-04-28: Released v0.3.1 — CLI renamed to `bedrock`; PyPI package renamed to `project-bedrock`; `agent-knowledge` kept as deprecated alias.
- 2026-04-28: Released v0.3.2 — `migrate-from-legacy` command; migration guide in docs/reference.md; cover image and demo GIF in README.

## 🔗 See Also

- [[packaging]] -- build system details
- [[testing]] -- what CI runs
- [[stack]] -- runtime requirements
