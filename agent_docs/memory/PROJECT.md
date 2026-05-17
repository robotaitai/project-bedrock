---
project: agent-knowledge
updated: 2026-05-17
---

# Project

## What this project is

Project Bedrock is a CLI and markdown workflow that turns a repository into a small project cockpit for AI agents. It keeps durable project context in `Memory/`, current priorities in `Work/`, and generated human inspection artifacts in `Views/`.

## Current product direction

Bedrock is moving toward a simpler public model:

- `Memory/` = what the project knows
- `Work/` = what matters now
- `Views/` = generated human inspection views

The product goal is to load less context, but better context, while keeping older vault layouts readable through compatibility fallbacks.

## How to navigate this memory

Start with `Memory/PROJECT.md`, then read `Work/NOW.md`. From there, load only the branches that match the task:

- `cli.md` for command behavior and repo workflows
- `architecture.md` for runtime paths, sync behavior, and storage layout
- `integrations.md` for Claude/Cursor/Codex/Gemini contracts
- `history-layer.md` for the lightweight chronology model

## Important context

- `bedrock/` is the active vault for this repository.
- A legacy `agent-knowledge/` tree still exists in the repo; older timeline notes and imported evidence were copied into `bedrock/` during cleanup so historical context is not lost.
- `History/` remains the durable chronology layer for releases, backfills, and major milestones.
- `Evidence/imports/` holds reference material worth keeping, but it is non-canonical.
- `Views/` is disposable generated output. It should stay small and can be rebuilt.
