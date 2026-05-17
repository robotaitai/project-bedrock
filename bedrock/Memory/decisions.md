---
note_type: decisions-index
updated: 2026-05-17
tags:
  - agent-knowledge
  - memory
  - decision
---

# Decisions

Use this file for important project decisions.

## Decision format

### YYYY-MM-DD, Decision title

**Decision:** What was decided.

**Why:** Why this decision was made.

**Impact:** What this changes.

**Related files:** Links to relevant Memory or Work items.

## Current decisions

### 2026-05-17, Clean the active Bedrock vault around Memory / Work / Views

**Decision:** Treat `bedrock/` as the active vault, preserve older history and imported evidence by copying the missing durable material from the legacy `agent-knowledge/` tree, stop creating per-sync capture YAML files, and write the compact retrieval index under `Views/graph/` instead of legacy `Outputs/`.

**Why:** The active vault had accumulated generated noise and duplicated history across two trees. The cleanup keeps older context available while making the working cockpit smaller and easier for agents to load.

**Impact:** `bedrock sync` no longer recreates `Evidence/captures/`; `Views/graph/knowledge-index.*` becomes the default deterministic retrieval index; `History/` and `Evidence/imports/` carry the older preserved context inside the active vault.

**Related files:** [PROJECT](PROJECT.md), [architecture](architecture.md), [cli](cli.md), [history-layer](history-layer.md), [Now](../Work/NOW.md)

## Legacy detailed log

Older numbered decisions remain in [decisions/decisions.md](decisions/decisions.md) for compatibility and historical reference.
