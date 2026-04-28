---
note_type: durable-branch
area: gotchas
updated: 2026-04-28
tags:
  - agent-knowledge
  - memory
  - gotchas
update_when: >
  A new non-obvious bug is hit and fixed; a workaround is discovered for a
  platform or environment issue; an existing gotcha is resolved and no longer
  applies.
---

# Gotchas

Known pitfalls, traps, and non-obvious behaviors.

## Shell Scripts

- `set -euo pipefail` + trailing `[ "$DRY_RUN" -eq 1 ] && log ...` causes exit 1 when test is false. Use `if/then` instead. See [[conventions]].
- `ship.sh` uses `python -m pytest -q` not bare `pytest` -- bare `pytest` fails outside venvs. See [[testing]].

## Python / pip

- macOS system Python refuses `pip install` ("externally managed"). Use brew python + `--user --break-system-packages`, or a venv. See [[stack]].
- Old system pip (e.g. 21.2.4) doesn't support PEP 660 editable installs with `pyproject.toml`. Need pip >= 21.3.
- Venv can get corrupted if multiple Python versions coexist in `.venv/lib/`. Fix: `rm -rf .venv` and recreate with explicit version.

## [[packaging|Packaging]]

- [[architecture|hatchling]] editable installs copy `src/` files to `site-packages`. Changes to `assets/` require rebuild to take effect in the wheel. Source Python files update live.
- pip may silently skip extracting `.mdc` files from wheels. Workaround: [[integrations|inline critical content in Python code]]. See [[decisions#006]].

## Sync

- `stamp_status` regex must use `[ \t]*` not `\s*` to avoid eating newlines across YAML frontmatter fields. Fixed in `runtime/sync.py`.

## Python Version Compatibility

- **f-string backslash (Python < 3.12)**: `re.sub(r'...', '', val)` cannot be called directly inside an f-string `{}` on Python 3.10/3.11 — raises `SyntaxError: f-string expression part cannot include a backslash`. Extract the call to a local variable first. Fixed in `runtime/site.py` (2026-04-28). Python 3.12+ relaxed this restriction.

## Recent Changes

- 2026-04-28: Documented f-string backslash `SyntaxError` on Python < 3.12; fixed in `runtime/site.py`.

## See Also

- [[conventions]] -- rules designed to avoid these
- [[testing]] -- tests that catch regressions
- [[decisions|Decisions]] -- why certain workarounds exist
