# AGENTS

This project uses the `agents-rules` v2 knowledge layout.

## Knowledge Entry Point

- Read and write project knowledge through `./agent-knowledge`
- Treat `./agent-knowledge` as a pointer to the real dedicated knowledge folder
- Keep durable knowledge in `Memory/`, raw evidence in `Evidence/raw/`, imported traces/docs in `Evidence/imports/`, and in-progress notes in `Sessions/`
- Treat generated structure, graph reports, and discovery summaries as evidence or outputs first, not durable memory
- Use `agent-knowledge/STATUS.md` to check sync state and health warnings

## Project Metadata

- Keep `.agent-project.yaml` current
- Use `.agentknowledgeignore` to exclude noisy paths from evidence and structural imports when needed
- Install repo-local hooks only when they remain easy to inspect and disable
- Prefer lightweight markdown updates over ad hoc scratch files

## TODO

Add project-specific stack, constraints, and conventions here once the project is connected.
