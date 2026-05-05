---
project: agent-knowledge
updated: 2026-04-30
---

# 🧠 Memory

## 🗂️ Areas

- [packaging](packaging.md) -- PyPI: project-bedrock, CLI: bedrock (alias: agent-knowledge deprecated), v0.4.1, pipx install recommended
- [cli](cli.md) -- CLI, 27 subcommands + /compact-context; completion, upgrade commands added; specialist cmds hidden from --help; v0.4.1
- [architecture](architecture.md) -- Runtime modules, path resolution, project config v4; site.py: table rendering, graph neighbor highlight, wikilink edges
- [integrations](integrations.md) -- Multi-tool detection (Cursor/Claude/Codex), bridge files; cursor rule now bedrock.mdc; posix paths in JSON
- [testing](testing.md) -- 151 tests, pytest, GitHub Actions CI (ubuntu + macos, py 3.9/3.12/3.13); CI fixed for v0.4.0 rename
- [stack](stack.md) -- Python 3.9+, Bash scripts, click, hatchling, no database/server
- [conventions](conventions.md) -- Naming rules, file layout conventions; update_when convention for durable-branch notes
- [deployments](deployments.md) -- CI pipeline, release process, PyPI publish
- [gotchas](gotchas.md) -- Known pitfalls; f-string backslash SyntaxError on Python < 3.12
- [history-layer](history-layer.md) -- Lightweight History/ diary, events.ndjson, backfill-history command
