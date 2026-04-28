    # agent-knowledge

**Project memory for teams whose developers happen to be AI agents.**

If you manage a team - humans, AI agents, or both - you already know the real
problem isn't writing code. It's making sure that what one developer changed,
decided, or learned today is still visible to the rest of the team next week.
Decisions get lost in chat history. Context evaporates between sessions. New
teammates start from zero. Senior knowledge becomes a tax on the senior.

`agent-knowledge` is a structured logbook that every developer on your team --
human or AI -- reads at the start of their session and updates at the end. No
chasing people for status updates, no archaeology in old PRs, no "ask the
senior dev". The next developer (or the next session) opens the project and
already knows what was done, where, and why.

It is designed for the manager who wants their team to leave a trail behind
them, without inventing yet another tool to ignore. It works with **Claude
Code**, **Cursor**, and **Codex** out of the box -- one command and every
session is wired to read and write the team's shared memory automatically.

Under the hood it's just markdown files and a CLI. No database, no server,
nothing to host. The vault lives in your repo, travels with your code, and
diffs cleanly in git so reviewing what your team learned this week is just a
PR review.

![agent-knowledge tour](docs/agent-knowledge-tour.gif)

## Install

```bash
pip install agent-knowledge-cli
```

PyPI package name: `agent-knowledge-cli`. CLI command and all docs: `agent-knowledge`.

## Quick Start

```bash
cd your-project
agent-knowledge init
```

That's it. Open the project in Claude Code or Cursor and the agent has
persistent memory automatically -- no manual prompting, no config, no setup.

`init` does everything in one shot:
- creates `./agent-knowledge/` as a real directory inside the repo (git-tracked)
- registers the project in `~/agent-os/projects/<slug>/` as a symlink back into the repo, so **every project on your machine shows up in one place** -- open `~/agent-os/projects/` in Obsidian and you have a single vault that spans all your teams' logbooks
- adds noisy subfolders (`Evidence/raw/`, `Sessions/`, `Outputs/site/`, ...) to `.gitignore` automatically
- installs project-local integration for both Claude Code and Cursor
- detects Codex and installs its bridge files if present
- bootstraps the memory tree and marks onboarding as `pending`
- imports repo history into `Evidence/` and backfills lightweight history from git

## Storage modes

By default, knowledge lives **inside** the repo at `./agent-knowledge/` (git-tracked) and
`~/agent-os/projects/<slug>/` is a symlink back to it. Curated knowledge (`Memory/`,
`History/`, `Evidence/imports/`) is committed normally; noisy subfolders are gitignored.

To keep knowledge **outside** the repo instead:

```bash
agent-knowledge init --external
```

In external mode:
- Knowledge lives in `~/agent-os/projects/<slug>/` (not committed)
- `./agent-knowledge` is a symlink into that folder

To convert an existing external-vault project to in-repo:

```bash
agent-knowledge migrate-to-local
```

## How It Works

Think of the vault as your team's shared notebook. It has a few clearly
separated sections so a casual scribble doesn't get mistaken for a confirmed
fact, and so the manager (you) can tell at a glance what is canon vs. what is
just chatter.

### Knowledge layers

| Folder | Role | Who writes here | Canonical? |
|--------|------|-----------------|-----------|
| `Memory/` | Decisions, conventions, architecture, gotchas -- the things you'd tell a new hire | Developer (deliberately, at session end) | Yes |
| `History/` | What happened, and when -- a dated trail of releases and milestones | The CLI (auto, from git) | Yes |
| `Evidence/` | Raw imports: docs, ADRs, PRs, screenshots, anything captured for context | Auto-imported on sync | No |
| `Outputs/` | Generated views: HTML site, search index, knowledge map | The CLI (auto) | No |
| `Sessions/` | Scratch state from the current session -- pruned aggressively | The CLI (auto) | No |

The discipline that makes this work: **only `Memory/` and `History/` are canon.**
Nothing imported, captured, or generated is ever treated as truth on its own.
A developer (or AI agent) has to consciously promote something into `Memory/`
for it to count -- which is exactly what you'd want from any team member
writing to a shared logbook.

## Project-local integration

The project carries everything it needs. Both Claude Code and Cursor get full
integration installed automatically -- hooks, runtime contracts, and slash commands.
No global config required.

## Obsidian-ready -- one vault for every project

Each project's `./agent-knowledge/` is a valid Obsidian vault on its own. But
the real payoff is `~/agent-os/projects/`: every project you've ever run
`init` in is registered there as a symlink. Open that single folder in
Obsidian and you have **a unified vault across all your teams' projects** --
with backlinks, graph view, and full-text search spanning every codebase you
manage. No per-project Obsidian setup. No re-opening windows when you switch
contexts. One window, every team.

![Obsidian graph view of a project knowledge vault](docs/obsidian-graph.png)

For a spatial canvas of the knowledge graph:

```bash
agent-knowledge export-canvas
# produces: agent-knowledge/Outputs/knowledge-export.canvas
```

The vault is designed to work well in Obsidian -- good markdown, YAML frontmatter,
branch-note convention, internal links. But everything works without it too.

### What gets installed

**Claude Code** (`.claude/`):

| File | Purpose |
|------|---------|
| `settings.json` | Lifecycle hooks: sync on SessionStart, Stop, PreCompact |
| `CLAUDE.md` | Runtime contract: knowledge layers, session protocol, onboarding |
| `commands/memory-update.md` | `/memory-update` slash command |
| `commands/system-update.md` | `/system-update` slash command |
| `commands/absorb.md` | `/absorb <file/folder>` slash command |

**Cursor** (`.cursor/`):

| File | Purpose |
|------|---------|
| `rules/agent-knowledge.mdc` | Always-on rule: loads memory context on every session |
| `hooks.json` | Lifecycle hooks: sync on start, update on write, sync on stop/compact |
| `commands/memory-update.md` | `/memory-update` slash command |
| `commands/system-update.md` | `/system-update` slash command |
| `commands/absorb.md` | `/absorb <file/folder>` slash command |

**Codex** (`.codex/`) -- installed when detected:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Agent contract with knowledge layer instructions |

### Session lifecycle

Hooks fire automatically -- the agent syncs memory at the start of every session    
and captures state at the end, with no manual intervention:

| Event | Claude Code | Cursor | What runs |
|-------|-------------|--------|-----------|
| Session start | SessionStart | session-start | `agent-knowledge sync` |
| File saved | -- | post-write | `agent-knowledge update` |
| Task complete | Stop | stop | `agent-knowledge sync` |
| Context compaction | PreCompact | preCompact | `agent-knowledge sync` |

The runtime contract ensures the agent reads `STATUS.md` and `Memory/MEMORY.md`
at the start of every session, with no manual prompting required.

### Slash commands

These are how the team writes to the logbook. Both work in any Claude Code
or Cursor session and are project-local -- `init` installed them.

| Command | Who runs it | When | What it does |
|---------|-------------|------|-------------|
| `/memory-update` | The developer at the end of a session | Before logging off, before opening a PR | Syncs state, then the agent reviews what happened this session, writes confirmed stable facts into `Memory/`, and summarizes what changed. **This is the team handoff** -- whoever (or whatever) opens the project next will read it. |
| `/system-update` | You, the manager | After upgrading `agent-knowledge-cli` | Refreshes the framework's plumbing: hooks, rules, commands, AGENTS.md. Has nothing to do with the project's knowledge content -- purely infrastructure. |

The intent: a developer should never finish a session without running
`/memory-update`. It is the equivalent of a daily standup writeup -- short,
factual, and the next person on the team gets it for free.

### Integration health

```bash
agent-knowledge doctor
```

Reports whether all integration files (settings, hooks, rules, commands) are
installed and current for both Claude Code and Cursor. If anything is stale or
missing, `doctor` tells you exactly what to run.

## Commands

| Command | What it does |
|---------|-------------|
| `init` | Set up a project -- knowledge in-repo by default, one command, no arguments |
| `sync` | Full sync: memory, history, git evidence, index |
| `ship` | Validate + sync + commit + push |
| `view` | Build site and open in browser |
| `doctor` | Validate setup, integration health, note staleness |

Other commands: `absorb`, `search`, `export-html`, `clean-import`, `refresh-system`, `backfill-history`, `compact`, `migrate-to-local`, `init --external`. Run `agent-knowledge --help` for the full list.

All write commands support `--dry-run` and `--json`. Run `agent-knowledge --help` for the full list.

## Static site export

Build a polished standalone site from your knowledge vault -- no Obsidian required:

```bash
agent-knowledge export-html       # generate
agent-knowledge view              # generate and open in browser
```

The generated site includes an overview page, branch tree navigation, note detail
view, evidence view, interactive graph view, and machine-readable `knowledge.json`
and `graph.json`. Opens via `file://` with no server needed.

Memory/ notes are always primary. Evidence and Outputs items are clearly marked
non-canonical.

## Automatic capture

Every sync and update event is automatically recorded in `Evidence/captures/`
as a small structured YAML file. This gives a lightweight history of what
changed and when -- without a database or background service.

Captures are evidence, not memory. They accumulate quietly and can be pruned
with `agent-knowledge compact`.

## Progressive retrieval

The knowledge index (`Outputs/knowledge-index.json` and `.md`) is regenerated
on every sync. Agents can:

1. Load the index first (cheap, a few KB)
2. Identify relevant branches from the shortlist
3. Load only the full note content they actually need

Use `agent-knowledge search <query>` for a quick shortlist query from the
command line or a hook.

## Clean web import

Import a web page as cleaned, non-canonical evidence:

```bash
agent-knowledge clean-import https://docs.example.com/api-reference
# produces: agent-knowledge/Evidence/imports/2025-01-15-api-reference.md
```

Strips navigation, ads, scripts, and boilerplate. Writes clean markdown with
YAML frontmatter marking it as non-canonical.

## Project history

`init` automatically backfills a lightweight history layer when run on an existing repo.
You can also run it explicitly:

```bash
agent-knowledge backfill-history
```

Creates `History/events.ndjson` (append-only event log), `History/history.md`
(human-readable summary), and `History/timeline/` (sparse milestone notes).

History records what happened over time -- releases, integrations, sync events.
It is not a git replacement. Current truth lives in `Memory/`.

## Keeping up to date

```bash
pip install -U agent-knowledge-cli
agent-knowledge refresh-system
```

`refresh-system` updates all integration files -- Claude settings/commands/contract,
Cursor hooks/rules/commands, `AGENTS.md` header, Codex config -- and version markers.
It never touches `Memory/`, `Evidence/`, `Sessions/`, or any curated knowledge.

`doctor` warns when the project integration is behind the installed version.

## Custom knowledge home

```bash
export AGENT_KNOWLEDGE_HOME=~/my-knowledge
agent-knowledge init
```

## Troubleshooting

```bash
agent-knowledge doctor          # validate setup and report health
agent-knowledge doctor --json   # machine-readable health check
```

Common issues:
- `./agent-knowledge` missing: run `agent-knowledge init` (or `agent-knowledge init --external` to keep knowledge outside the repo)
- Project still on external mode: run `agent-knowledge migrate-to-local` to switch the vault into the repo
- Onboarding still pending: paste the init prompt into your agent
- Claude not picking up memory: check `.claude/settings.json` exists -- run `agent-knowledge refresh-system`
- Cursor hooks not firing: check `.cursor/hooks.json` exists -- run `agent-knowledge refresh-system`
- Stale index: run `agent-knowledge sync`
- Large notes: run `agent-knowledge compact`
- **Wrong binary**: another tool may install a Node.js `agent-knowledge` that shadows ours. Check with `which -a agent-knowledge`. Fix: `export PATH="$(python3 -c 'import sysconfig; print(sysconfig.get_path("scripts"))'):$PATH"`

## Platform support

- **macOS** and **Linux** are fully supported.
- **Windows** is not currently supported (relies on `bash` and POSIX shell scripts).
- Python 3.9+ required.

## Package naming

| What | Value |
|------|-------|
| PyPI package | `agent-knowledge-cli` |
| CLI command | `agent-knowledge` |
| Python import | `agent_knowledge` |

## Development

```bash
git clone <repo-url>
cd agent-knowledge
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
python -m pytest tests/ -q
```
