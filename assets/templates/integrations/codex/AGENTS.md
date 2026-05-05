# Agent Knowledge: <project-name>

This project uses **Project Bedrock** for persistent project memory.
All knowledge lives in `./bedrock/`.

## Session Start

1. Read `./bedrock/STATUS.md`
2. If `onboarding: pending` — follow **First-Time Onboarding** below
3. If `onboarding: complete` — read `./bedrock/Memory/MEMORY.md`, then load branch notes relevant to the current task

Run at session start if shell is available:

```bash
bedrock sync --project .
```

---

## First-Time Onboarding

Only run this if `STATUS.md` shows `onboarding: pending`. Do NOT redo it if already complete.

1. Inspect project structure: manifests, package files, CI/CD config, docs
2. Review recent git history (last ~50 commits)
3. Infer functional domains from the repo — use the project's own terminology as branch names (e.g. `perception`, `navigation`), not generic ones (e.g. `architecture`)
4. Create one branch note per domain in `./bedrock/Memory/`. Each note under ~150 lines.
5. Link related notes to each other with relative markdown links
6. Update `./bedrock/Memory/MEMORY.md` with one-line summaries and links to all branches
7. Set `onboarding: complete` in `./bedrock/STATUS.md`

### Branch Layout

```
bedrock/Memory/
  MEMORY.md                    # root index — always read first
  stack.md                     # flat note when no subtopics needed
  perception/
    perception.md              # entry note = same name as folder
    fusion.md
  navigation/
    navigation.md
  decisions/
    decisions.md
    2025-01-15-use-raw-sql.md
```

Rules:
- Only confirmed facts go into `Memory/` — never speculate
- Raw material stays in `Evidence/`, generated views in `Outputs/`
- Notes stay under ~150 lines — split when too big
- Do NOT lump unrelated domains into one note

---

## Memory Update (end of session)

Run this mentally at the end of any session with meaningful work:

1. Edit the relevant branch note(s) in `./bedrock/Memory/`
   - Update `## Current State` with confirmed facts (replace stale entries)
   - Add a `YYYY-MM-DD — what changed` line to `## Recent Changes`
2. If any architectural, design, or tooling decisions were made, add them to `./bedrock/Memory/decisions/decisions.md` using the existing numbered format
3. Update `./bedrock/Memory/MEMORY.md` if branch one-line summaries changed
4. Run `bedrock sync --project .` to propagate

Write to memory when:
- A new feature, command, or module was completed
- An architectural decision was made or changed
- A gotcha, constraint, or pattern was confirmed

Skip writeback for read-only sessions, speculative changes, or session-specific context.

---

## Compact Context (when context window is long)

When the context window is getting long:

1. Update memory (see Memory Update above)
2. Write a brief handoff note summarizing what was done and what comes next
3. Start a fresh session — context will reload from `Memory/MEMORY.md`

---

## Knowledge Structure

| Folder | Purpose | Canonical? |
|--------|---------|:----------:|
| `Memory/` | Decisions, conventions, architecture, gotchas | Yes |
| `History/` | What happened and when | Yes |
| `Evidence/` | Raw imports, docs, extracts | No |
| `Outputs/` | Generated views, search index | No |

Reading order:
1. `Memory/MEMORY.md` — always first
2. Relevant branch entry notes
3. Leaf notes only when the specific detail is needed
4. Keep context lean — do not load branches unrelated to the current task
