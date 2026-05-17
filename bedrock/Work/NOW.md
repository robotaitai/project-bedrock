---
project: agent-knowledge
updated: 2026-05-17
---

# Now

## Current focus

Keep the active `bedrock/` vault small, project-shaped, and safe to load. The current cleanup consolidates older durable history into `bedrock/`, removes generated clutter, and aligns the repo with the `Memory / Work / Views` cockpit model.

## Next recommended actions

1. Verify whether the legacy `./agent-knowledge/` tree can be retired after one more pass over any remaining unique files.
2. Decide whether `Evidence/raw/git-recent.md` should remain default sync output or become an explicit on-demand export.
3. Keep tightening docs and runtime behavior around the smaller cockpit so future sessions do not drift back toward `Outputs/` and sync capture noise.

## Open questions

- Is there any durable material left in `./agent-knowledge/` that still needs to be migrated into `./bedrock/`?
- Should the retrieval index stay in `Views/graph/` long-term, or should Bedrock eventually gain a dedicated hidden runtime cache?

## Risks

- Dual-vault confusion remains until the legacy `./agent-knowledge/` tree is fully retired.
- Some older docs or scripts may still refer to `Outputs/knowledge-index.*` or sync capture behavior.

## Context to load first

- Memory/PROJECT.md
- Memory/decisions.md
- Memory/architecture.md
- Memory/cli.md
- Memory/history-layer.md
