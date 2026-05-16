# bedrock

This project uses **bedrock** as a small project cockpit for AI-agent work.
All project context lives in `./bedrock/`.

## Project cockpit

- `Memory/` = what the project knows
- `Work/` = what matters now
- `Views/` = generated human inspection views

Legacy folders such as `History/`, `Evidence/`, `Outputs/`, or `Sessions/`
may still exist for compatibility. They are not the main user-facing model.

## On session start

If `./bedrock/` does not exist but `./agent-knowledge/` does, this project needs migration:

```bash
bedrock migrate-vault && bedrock refresh-system
```

Otherwise:

1. Read `./bedrock/STATUS.md`
2. If `onboarding: pending` -- read `AGENTS.md` and perform First-Time Onboarding
3. If `onboarding: complete` -- read `./bedrock/Memory/PROJECT.md`
4. Read `./bedrock/Work/NOW.md`
5. Load only the relevant Memory branches for the task

## After meaningful work

- Update stable project knowledge in `./bedrock/Memory/`
- Update current priorities and open loops in `./bedrock/Work/`
- Run `/memory-update`

## Periodic

- Run `/system-update` every few sessions to refresh integration files

## When the context window is getting long

- Run `/compact-context`
