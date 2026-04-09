---
name: memory-management
description: Read on session start. Manages adaptive durable memory across conversations. Use when reading or writing curated memory under agent-knowledge/Memory/.
---

# Memory Management

Manages the adaptive project memory tree. Read this skill at session start.

The memory directory path is provided by the session-start hook
(e.g., `~/.cursor/projects/<project-id>/memory/MEMORY.md`).
For project-shared memory, the canonical repo entrypoint is `./agent-knowledge`.
Durable curated memory lives at `agent-knowledge/Memory/MEMORY.md`.

---

## Tree structure

```text
agent-knowledge/
  Memory/
    MEMORY.md               <- root memory note -- always loaded, keep it short
    <topic>.md              <- flat branch note (no subtopics needed)
    <topic>/
      <topic>.md            <- branch entry note (same name as folder)
      <subtopic>.md         <- leaf notes beside the entry
    decisions/
      decisions.md          <- decision log, newest first
      YYYY-MM-DD-slug.md
  Evidence/
    raw/
    imports/
  Sessions/                 <- milestone-oriented temporary state
  Outputs/
  Dashboards/
  STATUS.md
```

### Branch convention

- **Folder name = ontology node**. The folder is the topic.
- **Same-name entry note** (`<topic>/<topic>.md`) = summary and routing for the branch.
- **Flat note** (`<topic>.md`) when there are no subtopics yet.
- **Promote to folder** only when the topic grows subtopics.
- **Do not create deep trees** automatically. Start flat. Grow only when justified.
- **Use the project's own terminology** for branch names, not generic templates.

Evidence (`agent-knowledge/Evidence/raw/` and `agent-knowledge/Evidence/imports/`) is separate from curated memory (`agent-knowledge/Memory/`).
Never copy raw evidence into memory. Distill only stable, verified facts.
Generated structural outputs belong in `Evidence/` or `Outputs/` first.
Only curated notes under `Memory/` are durable project knowledge.

---

## Durable note requirements

Every durable memory note must have YAML frontmatter.

Branch notes use these sections:

| Section | Content | Updated when |
|---------|---------|--------------|
| **Purpose** | One sentence: what this area covers | At creation; rarely changes |
| **Current State** | Verified facts about what is true now | Every writeback |
| **Recent Changes** | Rolling log, YYYY-MM-DD format, pruned after ~4 weeks | After meaningful changes |
| **Decisions** | Links to `decisions/YYYY-MM-DD-slug.md` | When a decision is recorded |
| **Open Questions** | Unresolved items for future sessions | When identified; removed when resolved |

Use markdown links for portability. Avoid wiki-links and tool-specific metadata.

---

## Reading the tree

1. `Memory/MEMORY.md` loads automatically first.
2. Identify which branch notes the task touches from the Branches section.
3. Read only the relevant branch entry notes -- keep context lean.
4. For branches with folders, read subtopic notes only if the specific detail is needed.
5. Do not read branches unrelated to your task.

---

## Writing to the tree

- **Memory/MEMORY.md**: short branch summaries + links. No dense detail.
- **Branch entry note**: all durable facts for that area, organized by section.
- **Subtopic note**: created only when an entry note grows beyond ~150 lines.
- **Decision file**: one file per architectural decision, linked from the branch.

Format for facts: lead with the fact. For lessons: add **Why:** and **How to apply:**.

---

## Bootstrap

If `agent-knowledge/Memory/MEMORY.md` is missing or empty:
-> Read and follow the `project-ontology-bootstrap` skill before any other work.

---

## When to write back

Write to memory when any of these happen:
- A new architectural decision is made
- A pattern or convention is confirmed
- A gotcha is discovered
- A feature area is substantially completed or changed
- A recurring mistake is corrected

Do NOT write:
- In-progress task state -> session file only
- Speculative plans -> wait until confirmed
- Facts already in git history that are easily re-discoverable
- Raw evidence -> keep it in `Evidence/`
- Machine-generated summaries -> keep in `Evidence/` or `Outputs/` until curated

---

## Compaction

When `Memory/MEMORY.md` grows noisy or a branch note exceeds ~150 lines:
-> Read and follow the `memory-compaction` skill.

---

## Explicit user requests

- "Remember X" -> save it immediately to the relevant branch note
- "Forget X" -> remove or mark stale in the relevant branch note
- "Why did we choose X" -> read `decisions/decisions.md` and the linked decision file
