# bedrock

This project uses **bedrock** for persistent project memory.
All knowledge lives in `./bedrock/`.

## On session start

1. Read `./bedrock/STATUS.md`
2. If `onboarding: pending` -- read `AGENTS.md` and perform First-Time Onboarding
3. If `onboarding: complete` -- read `./bedrock/Memory/MEMORY.md`
   - Load branch notes relevant to the current task
   - Scan `./bedrock/History/history.md` for recent activity if useful

## Knowledge layers

| Layer | Canonical? | Use for |
|-------|-----------|---------|
| `Memory/` | Yes | Stable project truth -- write here |
| `History/` | Yes (diary) | What happened over time |
| `Evidence/` | No | Raw imports -- never promote to Memory |
| `Outputs/` | No | Generated views -- never treat as truth |

## After meaningful work

- Write confirmed facts to `./bedrock/Memory/<branch>.md`
- Run `/memory-update` — sync, update branches, summarize what changed

## Periodic (every few sessions)

- Run `/system-update` to refresh integration files to the latest framework version

Keep ontology small and project-native. Do not force generic templates.
