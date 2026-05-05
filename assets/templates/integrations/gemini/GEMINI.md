# Project Bedrock — Memory Contract

This project uses **Project Bedrock** for persistent project memory.
All knowledge lives in `./bedrock/`.

## Session Start

1. Read `./bedrock/STATUS.md`
2. If `onboarding: pending` — read `AGENTS.md` and follow First-Time Onboarding
3. If `onboarding: complete` — read `./bedrock/Memory/MEMORY.md`, then load branch notes relevant to the current task

Run at session start if shell is available:

```bash
bedrock sync --project .
```

## Memory Update (end of session)

After meaningful work:

1. Edit the relevant branch note(s) in `./bedrock/Memory/`
   - Update `## Current State` with confirmed facts
   - Add a `YYYY-MM-DD — what changed` line to `## Recent Changes`
2. If any architectural, design, or tooling decisions were made, add them to `./bedrock/Memory/decisions/decisions.md` using the existing numbered format
3. Update `./bedrock/Memory/MEMORY.md` if branch summaries changed
4. Run `bedrock sync --project .`

Write to memory when: a feature was completed, a decision was made, a gotcha was found.
Skip for read-only sessions or speculative work.

## Knowledge Structure

| Folder | Purpose | Canonical? |
|--------|---------|:----------:|
| `Memory/` | Decisions, conventions, architecture, gotchas | Yes |
| `History/` | Dated event log | Yes |
| `Evidence/` | Raw imports, extracts | No |
| `Outputs/` | Generated views | No |
