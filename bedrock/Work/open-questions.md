---
project: agent-knowledge
updated: 2026-05-17
---

# Open Questions

Questions that are not resolved yet.

## Open

- Should the legacy `./agent-knowledge/` directory remain in the repo after the active `./bedrock/` vault has all durable history?
  - Why it matters: two parallel vault trees are the main remaining source of confusion.
  - Related context: `Memory/PROJECT.md`, `History/`, `Evidence/imports/`

- Is `Evidence/raw/git-recent.md` still worth generating on every sync?
  - Why it matters: it is the last automatically refreshed non-canonical file in the active vault.
  - Related context: `Memory/architecture.md`, `Memory/history-layer.md`
