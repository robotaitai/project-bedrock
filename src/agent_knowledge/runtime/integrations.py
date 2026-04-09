"""Auto-detect and install tool integrations (Cursor, Claude, Codex)."""

from __future__ import annotations

import shutil
from pathlib import Path

from .paths import get_assets_dir

TOOLS = ("cursor", "claude", "codex")


def detect(repo: Path) -> dict[str, bool]:
    """Return which tools are detected in the repo."""
    return {
        "cursor": (repo / ".cursor").is_dir(),
        "claude": (repo / ".claude").is_dir() or (repo / "CLAUDE.md").is_file(),
        "codex": (repo / ".codex").is_dir(),
    }


def _copy_template(src: Path, dst: Path, replacements: dict[str, str], *, force: bool = False) -> str:
    """Copy a template file with placeholder substitutions. Returns action taken."""
    if dst.exists() and not force:
        return "exists"
    dst.parent.mkdir(parents=True, exist_ok=True)
    content = src.read_text()
    for placeholder, value in replacements.items():
        content = content.replace(placeholder, value)
    dst.write_text(content)
    return "created" if not dst.exists() else "updated"


_CURSOR_RULE = """\
---
description: Agent knowledge system -- read on every session
alwaysApply: true
---

This project uses agent-knowledge for persistent memory.

On session start:
1. Read `./agent-knowledge/STATUS.md`
2. If `onboarding: pending`, read `AGENTS.md` and follow the First-Time Onboarding instructions
3. If `onboarding: complete`, read `./agent-knowledge/Memory/MEMORY.md` for project context
"""


def install_cursor(repo: Path, *, dry_run: bool = False, force: bool = False) -> list[str]:
    """Install Cursor hooks and rules integration."""
    assets = get_assets_dir()
    actions = []
    repo_abs = str(repo.resolve())

    # Hooks
    hooks_src = assets / "templates" / "integrations" / "cursor" / "hooks.json"
    hooks_dst = repo / ".cursor" / "hooks.json"
    if hooks_dst.exists() and not force:
        actions.append("  exists: .cursor/hooks.json")
    elif dry_run:
        actions.append("  [dry-run] would create: .cursor/hooks.json")
    else:
        hooks_dst.parent.mkdir(parents=True, exist_ok=True)
        content = hooks_src.read_text().replace("<repo-path>", repo_abs)
        hooks_dst.write_text(content)
        actions.append("  created: .cursor/hooks.json")

    # Rule
    rule_dst = repo / ".cursor" / "rules" / "agent-knowledge.mdc"
    if rule_dst.exists() and not force:
        actions.append("  exists: .cursor/rules/agent-knowledge.mdc")
    elif dry_run:
        actions.append("  [dry-run] would create: .cursor/rules/agent-knowledge.mdc")
    else:
        rule_dst.parent.mkdir(parents=True, exist_ok=True)
        rule_dst.write_text(_CURSOR_RULE)
        actions.append("  created: .cursor/rules/agent-knowledge.mdc")

    return actions


def install_claude(repo: Path, *, dry_run: bool = False, force: bool = False) -> list[str]:
    """Install Claude CLAUDE.md integration."""
    assets = get_assets_dir()
    actions = []

    src = assets / "templates" / "integrations" / "claude" / "CLAUDE.md"
    dst = repo / "CLAUDE.md"

    if dst.exists() and not force:
        actions.append(f"  exists: CLAUDE.md")
    elif dry_run:
        actions.append(f"  [dry-run] would create: CLAUDE.md")
    else:
        shutil.copy2(src, dst)
        actions.append(f"  created: CLAUDE.md")

    return actions


def install_codex(repo: Path, *, dry_run: bool = False, force: bool = False) -> list[str]:
    """Install Codex .codex/AGENTS.md integration."""
    assets = get_assets_dir()
    actions = []

    src = assets / "templates" / "integrations" / "codex" / "AGENTS.md"
    dst = repo / ".codex" / "AGENTS.md"

    if dst.exists() and not force:
        actions.append(f"  exists: .codex/AGENTS.md")
    elif dry_run:
        actions.append(f"  [dry-run] would create: .codex/AGENTS.md")
    else:
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dst)
        actions.append(f"  created: .codex/AGENTS.md")

    return actions


_INSTALLERS = {
    "cursor": install_cursor,
    "claude": install_claude,
    "codex": install_codex,
}


def install_all(
    repo: Path,
    detected: dict[str, bool],
    *,
    dry_run: bool = False,
    force: bool = False,
) -> dict[str, list[str]]:
    """Install bridge files for detected integrations.

    Cursor is always installed (hooks + rule) because it is the primary agent
    IDE and the hooks/rules have no effect when Cursor is not in use.

    Claude and Codex bridges are only installed when their marker directories
    (.claude/ or .codex/) are detected, to avoid polluting repos that don't
    use those tools.
    """
    results: dict[str, list[str]] = {}

    # Cursor: always install -- hooks/rules are inert outside Cursor
    results["cursor"] = _INSTALLERS["cursor"](repo, dry_run=dry_run, force=force)

    # Claude / Codex: install only when detected
    for tool in ("claude", "codex"):
        if detected.get(tool, False):
            results[tool] = _INSTALLERS[tool](repo, dry_run=dry_run, force=force)

    return results
