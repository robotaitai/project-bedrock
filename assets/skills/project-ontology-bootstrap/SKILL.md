---
name: project-ontology-bootstrap
description: Bootstrap an adaptive project knowledge tree. Use when agent-knowledge/Memory/MEMORY.md is missing, broken, or too generic.
---

# Project Ontology Bootstrap

Creates a minimal knowledge scaffold, then the agent infers the ontology from the
real project. Run this once -- then maintain with the writeback rule.

## When to use

- `agent-knowledge/Memory/MEMORY.md` does not exist or is empty
- `Memory/MEMORY.md` exists but is still generic bootstrap content
- User says "initialize memory", "bootstrap memory", or "set up project memory"
- Starting work on an inherited repo with no prior agent memory

---

## Step 0 -- Verify the local pointer

The project entrypoint is `./agent-knowledge`.

- `./agent-knowledge` must be a symlink or junction to the real dedicated knowledge folder
- The external folder is the source of truth
- Manual and scripted bootstrap still write through `./agent-knowledge` as the local handle

If the pointer does not exist yet, create it first with:

```bash
scripts/install-project-links.sh --slug <project-slug> --repo /path/to/project
```

---

## Step 1 -- Run the bootstrap script

```bash
scripts/bootstrap-memory-tree.sh /path/to/project
```

This creates a minimal scaffold:
```text
agent-knowledge/
  Memory/
    MEMORY.md           <- root durable memory note
    decisions/
      decisions.md      <- decision log (same-name convention)
  Evidence/
    raw/
    imports/
  Sessions/
  Outputs/
  Dashboards/
  Templates/
  .obsidian/
  STATUS.md
```

The script detects a profile hint (web-app, robotics, ml-platform, or hybrid) and
stores it in STATUS.md. The hint does NOT create branch notes -- that is the agent's job.

---

## Step 2 -- Inspect the repo and infer the ontology

After the scaffold exists, inspect:
- Manifests and lockfiles
- Directory structure
- Docs (README.md, AGENTS.md, CLAUDE.md, docs/)
- Config files
- Test directories
- Workflow files
- Any evidence already present under Evidence/

From these signals, determine the project's natural decomposition. Use the project's
own terminology, not generic template names.

---

## Step 3 -- Create initial branch notes

Create a small set of initial branches (2-4 is typical). Use the same-name convention:

- Small topic with no subtopics: `Memory/<topic>.md`
- Bigger topic with subtopics: `Memory/<topic>/<topic>.md`

Example for a robotics project:
```text
Memory/
  MEMORY.md
  stack.md
  perception/
    perception.md
  navigation/
    navigation.md
  decisions/
    decisions.md
```

Rules:
- Use the project's own decomposition, not generic templates
- Start with 2-4 branches; grow only when justified
- Do not create empty placeholder branches
- Do not force categories like "conventions" or "gotchas" unless they clearly apply
- Each branch entry note should have frontmatter, Purpose, Current State, Recent Changes,
  Decisions, and Open Questions sections

---

## Step 4 -- Seed from immediately available facts

For each branch you create, seed it with verified facts:

- Read manifests, configs, docs, and directory structure
- Write only confirmed facts to Current State
- Do not invent facts or speculate
- If a source is machine-generated, verify against the repo before writing to Memory/

---

## Step 5 -- Update Memory/MEMORY.md

Add links to each branch note in the Branches section:

```markdown
## Branches

- [Stack](stack.md) -- Python 3.10, ROS2 Humble, colcon build system
- [Perception](perception/perception.md) -- Camera pipeline, YOLO detection, depth fusion
- [Navigation](navigation/navigation.md) -- Nav2 stack, custom costmap layers
```

---

## Step 6 -- Trigger history backfill

Bootstrap creates structure only. To fill it with real project history:

```bash
scripts/import-agent-history.sh /path/to/project
```

Then follow the `history-backfill` skill to distill evidence into memory.

---

## Output checklist

After bootstrap, verify:
- [ ] `agent-knowledge/Memory/MEMORY.md` exists and uses YAML frontmatter
- [ ] `agent-knowledge/Memory/decisions/decisions.md` exists
- [ ] Each branch note has a Purpose and at least one entry in Current State
- [ ] `agent-knowledge/Evidence/raw/` and `agent-knowledge/Evidence/imports/` exist
- [ ] `agent-knowledge/Sessions/` exists
- [ ] `Memory/MEMORY.md` is still short enough to scan quickly
- [ ] No INDEX.md files were created
