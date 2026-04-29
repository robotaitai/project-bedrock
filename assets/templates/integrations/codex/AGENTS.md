# Agent Knowledge

This project uses bedrock for persistent project memory.
Read the root `AGENTS.md` for knowledge management instructions.
Check `./bedrock/STATUS.md` for onboarding state.

If onboarding is pending, follow the instructions in the root AGENTS.md before other work.

## Session Start

Run at the beginning of each session:

```bash
bedrock sync --project . && bedrock refresh-system --project .
```

This syncs memory branches, rolls up sessions, refreshes git evidence, updates the knowledge index, and refreshes integration files.

## Memory Maintenance

After completing meaningful work in a session:

1. Write updated facts directly to `./bedrock/Memory/<branch>.md`
   - Update the relevant branch note
   - Add a dated entry to the `Recent Changes` section
   - Update `./bedrock/Memory/MEMORY.md` if branch summaries changed
2. Run `bedrock sync --project .` to propagate changes

Write to memory when:
- An architectural decision was made
- A new command, module, or feature was completed
- A gotcha or constraint was discovered
- A pattern or convention was confirmed
- Test count or CI setup changed

## Periodic (every few sessions)

Run to keep integration files current with the installed framework:

```bash
bedrock refresh-system --project .
```

Do NOT write to memory for:
- Read-only exploration with no conclusions
- Speculative or unconfirmed changes
- Session-specific context that won't matter next session

## Knowledge Structure

- `./bedrock/Memory/` -- Canonical project knowledge (write here)
- `./bedrock/Evidence/` -- Non-canonical: imports, extracts
- `./bedrock/Outputs/` -- Generated views (never canonical)
- `./bedrock/History/` -- Lightweight diary, events, releases
