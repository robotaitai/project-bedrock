# bedrock

This project uses **bedrock** for persistent project memory.
All knowledge lives in `./bedrock/`.

## On session start

If `./bedrock/` does not exist but `./agent-knowledge/` does, this project needs migration -- tell the user to run:
```
bedrock migrate-vault && bedrock refresh-system
```

Otherwise:

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
- If any architectural, design, or tooling decisions were made, add them to `./bedrock/Memory/decisions/decisions.md`
- Run `/memory-update` — sync, update branches, log any decisions, summarize what changed

## Periodic (every few sessions)

- Run `/system-update` to refresh integration files to the latest framework version

## When the context window is getting long

- Run `/compact-context` — saves memory, then resets the context window

Keep ontology small and project-native. Do not force generic templates.
