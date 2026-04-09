---
name: memory-compaction
description: Compact and prune the memory tree when it grows large or stale. Use when Memory/MEMORY.md grows noisy, branch notes exceed 150 lines, or when explicitly asked to clean up memory.
---

# Memory Compaction

Reorganizes the memory tree to keep it scannable without losing durable facts.

Run this when `compact-memory.sh` reports warnings, or proactively after dense work periods.

---

## Invariants -- never violate

- Every durable fact must survive compaction (move or merge, never delete)
- `Memory/MEMORY.md` must stay short and scannable
- Every branch folder must contain a same-name entry note (`<topic>/<topic>.md`)
- Evidence files are never touched during compaction

---

## Step 1 -- Audit

Run the report script first:

```bash
scripts/compact-memory.sh /path/to/project
```

Note which files are flagged as:
- `CRITICAL` (>200 lines) -- act immediately
- `WARNING` (>150 lines) -- split at next opportunity
- `stub or empty` -- populate or remove

---

## Step 2 -- Prune stale entries

In each branch note, remove or update entries that are:

- **Superseded**: a newer entry contradicts the old one -> remove the old, update the new
- **Dead reference**: refers to a path, API, or dependency that no longer exists -> remove
- **Speculation never confirmed**: still marked with "might", "probably", "TODO: verify" -> remove or move to Open Questions
- **Recent Changes too old**: entries older than ~4 weeks -> move stable facts to Current State, drop transient ones

Do not prune:
- Gotchas and lessons (even old ones are valuable if the risk still exists)
- Decision rationale (even for reversed decisions -- mark as `Status: reversed`)

---

## Step 3 -- Split large branch notes

If a branch note exceeds ~150 lines:

1. Identify the dominant sub-topic that makes it large
2. Promote the branch to a folder if it is still a flat note:
   - Create `Memory/<topic>/` directory
   - Move `Memory/<topic>.md` to `Memory/<topic>/<topic>.md`
3. Create `Memory/<topic>/<subtopic>.md` for the extracted content
4. Replace the moved section in the entry note with a link:
   ```markdown
   See [subtopic.md](subtopic.md) for details.
   ```
5. Update `Memory/MEMORY.md` branch link if the path changed

---

## Step 4 -- Merge overlapping thin notes

If two branch notes cover the same ground and together are under ~100 lines:

1. Choose the name that better describes the combined scope
2. Merge content, resolving any contradictions (newer wins)
3. Delete the merged file
4. Update `Memory/MEMORY.md` to remove the deleted entry and update the surviving one

---

## Step 5 -- Compact Memory/MEMORY.md

The root note must be scannable at a glance. Keep:

```markdown
- one short summary per branch
- markdown links to the branch notes
- only the most useful open questions
```

Remove:
- Branches with empty files that will not be populated
- Duplicate entries

Add:
- Any branch notes that exist but are not yet linked

---

## Step 6 -- Update decisions/decisions.md

Verify every file in `decisions/` is listed in `decisions/decisions.md`.
Remove entries for deleted decision files.
Mark superseded decisions with `~~strikethrough~~` or `[reversed]` in the log.

---

## Output checklist

- [ ] `compact-memory.sh` shows no CRITICAL or WARNING flags
- [ ] `Memory/MEMORY.md` is short and readable
- [ ] No branch note exceeds 150 lines
- [ ] All branch notes are linked from `Memory/MEMORY.md`
- [ ] Every branch folder has a same-name entry note
- [ ] `decisions/decisions.md` is current
