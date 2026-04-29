Perform a project memory update.

Steps:
1. Run in terminal: `bedrock sync --project .`
2. Review this session's work and identify what stable project knowledge changed
3. For each changed area, update the relevant `./bedrock/Memory/<branch>.md`:
   - Edit the Current State section with confirmed facts
   - Add a dated entry to Recent Changes: `YYYY-MM-DD -- what changed`
4. If branch summaries changed, update `./bedrock/Memory/MEMORY.md`
5. Summarize: what branches were updated, what was skipped, and why

Write to Memory only for stable, confirmed facts. Skip speculative or session-only context.
Evidence and captures go to `Evidence/`, not `Memory/`.
