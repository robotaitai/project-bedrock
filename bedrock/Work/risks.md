---
project: agent-knowledge
updated: 2026-05-17
---

# Risks

Known project risks.

## Open risks

- Risk: the legacy `agent-knowledge/` tree may still contain unreviewed unique files.
  - Why it matters: deleting it too early could drop older context.
  - Mitigation: compare it against `bedrock/` before retirement and migrate any remaining durable content first.
  - Related context: `Memory/PROJECT.md`, `Work/open-questions.md`

- Risk: compatibility code and stale docs can quietly recreate or normalize old `Outputs/` paths.
  - Why it matters: the cleaned cockpit can regress into a noisier structure over time.
  - Mitigation: keep tests and docs aligned with `Memory / Work / Views`, and review sync/index behavior when adding new generated artifacts.
  - Related context: `Memory/architecture.md`, `Memory/cli.md`
