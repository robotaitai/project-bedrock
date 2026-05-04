---
note_type: output
generated: 2026-05-04T13:17:43Z
canonical: false
---

# Knowledge Index

> Generated output. Not canonical. Do not treat as Memory.

Generated: 2026-05-04T13:17:43Z  
Total notes: 14

## Memory [canonical]

- **Memory** `Memory/MEMORY.md` (branch entry)
  - [packaging](packaging.md) -- PyPI: project-bedrock, CLI: bedrock (alias: agent-knowledge deprecated), v0.4.1, pipx ins...
- **Architecture** `Memory/architecture.md`
  Core design: path resolution, runtime modules, project config, integrations, knowledge vault model. Two storage modes co...
- **CLI** `Memory/cli.md`
  Design and implementation of the bedrock command-line interface. Built on click >= 8.0 with a @click.group() top-level. ...
- **Conventions** `Memory/conventions.md`
  Coding patterns, naming, and design rules. - CLI command names use hyphens: bedrock graphify-sync - Python package uses ...
- **Decision Log** `Memory/decisions/decisions.md`
  Architectural and process decisions for agent-knowledge. - Date: 2026-04-08 - Context: Needed a modern pyproject.toml-on...
- **Deployments** `Memory/deployments.md`
  Release, CI, and distribution strategy. 0.3.2 (tagged v0.3.2). See packaging. GitHub Actions (.github/workflows/ci.yml):...
- **Gotchas** `Memory/gotchas.md`
  Known pitfalls, traps, and non-obvious behaviors. - set -euo pipefail + trailing [ "$DRY_RUN" -eq 1 ] && log ... causes ...
- **History Layer** `Memory/history-layer.md`
  Lightweight project diary. Records what happened over time without becoming a second knowledge base. History/ events.ndj...
- **Integrations** `Memory/integrations.md`
  Multi-tool detection and bridge file installation for Cursor, Claude, and Codex. Called by init via detect() then instal...
- **Packaging** `Memory/packaging.md`
  Python packaging strategy for making bedrock pip-installable. - Backend: hatchling via pyproject.toml - Layout: src-layo...
- **Stack** `Memory/stack.md`
  Languages, runtimes, frameworks, and tooling used by agent-knowledge. - Python 3.9+ -- package code, CLI, tests - Bash -...
- **Testing** `Memory/testing.md`
  Test strategy for packaging validation and CLI correctness. - Framework: pytest (dev dependency). - 151 tests across 2 f...

## Evidence [non-canonical]

- **Recent Git History** `Evidence/raw/git-recent.md`
  Last 30 commits as of 2026-05-04. a509a8a feat: Mermaid diagram support in site.py + diagrams in memory notes 59d36e6 fi...

## Outputs [non-canonical]

- **Knowledge Index** `Outputs/knowledge-index.md`
  > Generated output. Not canonical. Do not treat as Memory. Generated: 2026-05-04T13:14:34Z Total notes: 14 - Memory Memo...

