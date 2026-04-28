# Reference

Detailed guides for every feature. See the main [README](../README.md) for quick start and overview.

---

## Static site export

Build a polished standalone site from your knowledge vault -- no Obsidian required:

```bash
bedrock export-html       # generate
bedrock view              # generate and open in browser
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
with `bedrock compact`.

## Progressive retrieval

The knowledge index (`Outputs/knowledge-index.json` and `.md`) is regenerated
on every sync. Agents can:

1. Load the index first (cheap, a few KB)
2. Identify relevant branches from the shortlist
3. Load only the full note content they actually need

Use `bedrock search <query>` for a quick shortlist query from the
command line or a hook.

## Clean web import

Import a web page as cleaned, non-canonical evidence:

```bash
bedrock clean-import https://docs.example.com/api-reference
# produces: agent-knowledge/Evidence/imports/2025-01-15-api-reference.md
```

Strips navigation, ads, scripts, and boilerplate. Writes clean markdown with
YAML frontmatter marking it as non-canonical.

## Project history

`init` automatically backfills a lightweight history layer when run on an existing repo.
You can also run it explicitly:

```bash
bedrock backfill-history
```

Creates `History/events.ndjson` (append-only event log), `History/history.md`
(human-readable summary), and `History/timeline/` (sparse milestone notes).

History records what happened over time -- releases, integrations, sync events.
It is not a git replacement. Current truth lives in `Memory/`.

## Keeping up to date

```bash
pip install -U project-bedrock
bedrock refresh-system
```

`refresh-system` updates all integration files -- Claude settings/commands/contract,
Cursor hooks/rules/commands, `AGENTS.md` header, Codex config -- and version markers.
It never touches `Memory/`, `Evidence/`, or any curated knowledge.

`bedrock doctor` warns when the project integration is behind the installed version.

## Custom knowledge home

```bash
export AGENT_KNOWLEDGE_HOME=~/my-knowledge
bedrock init
```

## Troubleshooting

```bash
bedrock doctor          # validate setup and report health
bedrock doctor --json   # machine-readable health check
```

Common issues:
- `./agent-knowledge` missing: run `bedrock init` (or `bedrock init --external` to keep knowledge outside the repo)
- Project still on external mode: run `bedrock migrate-to-local` to switch the vault into the repo
- Onboarding still pending: paste the init prompt into your agent
- Claude not picking up memory: check `.claude/settings.json` exists -- run `bedrock refresh-system`
- Cursor hooks not firing: check `.cursor/hooks.json` exists -- run `bedrock refresh-system`
- Stale index: run `bedrock sync`
- Large notes: run `bedrock compact`
- **Wrong binary**: another tool may install a Node.js `agent-knowledge` binary that shadows ours. Check with `which -a bedrock`. Fix: `export PATH="$(python3 -c 'import sysconfig; print(sysconfig.get_path("scripts"))'):$PATH"`

## Platform support

- **macOS** and **Linux** are fully supported.
- **Windows** is not currently supported (relies on `bash` and POSIX shell scripts).
- Python 3.9+ required.

## Package naming

| What | Value |
|------|-------|
| PyPI package | `project-bedrock` |
| CLI command | `bedrock` (alias: `agent-knowledge`, deprecated) |
| Python import | `agent_knowledge` |

## Development

```bash
git clone <repo-url>
cd agent-knowledge
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
python -m pytest tests/ -q
```
