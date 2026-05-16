"""Asset and path resolution for the bedrock package."""

from __future__ import annotations

from pathlib import Path

_cached_assets_dir: Path | None = None

_MEMORY_ROOT_CANDIDATES = (
    Path("Memory") / "PROJECT.md",
    Path("Memory") / "MEMORY.md",
)
_DECISIONS_LOG_CANDIDATES = (
    Path("Memory") / "decisions.md",
    Path("Memory") / "decisions" / "decisions.md",
)


def get_assets_dir() -> Path:
    """Return the root of the bundled assets directory.

    When installed via pip, assets live under agent_knowledge/assets/.
    When running from a repo checkout (editable install), falls back to the
    repository root where scripts/, templates/, etc. live directly.
    """
    global _cached_assets_dir
    if _cached_assets_dir is not None:
        return _cached_assets_dir

    marker = Path("scripts", "lib", "knowledge-common.sh")

    # Installed package: assets/ is a sibling of runtime/
    package_assets = Path(__file__).resolve().parent.parent / "assets"
    if (package_assets / marker).is_file():
        _cached_assets_dir = package_assets
        return _cached_assets_dir

    # Dev fallback: repo_root/assets/ (src/agent_knowledge/runtime -> 4 levels up)
    repo_assets = Path(__file__).resolve().parent.parent.parent.parent / "assets"
    if (repo_assets / marker).is_file():
        _cached_assets_dir = repo_assets
        return _cached_assets_dir

    raise FileNotFoundError(
        "Cannot locate bedrock assets. "
        "Ensure the package is installed correctly or you are running from the repo checkout."
    )


def get_script(name: str) -> Path:
    """Return the path to a bundled script (shell or Python)."""
    path = get_assets_dir() / "scripts" / name
    if not path.is_file():
        raise FileNotFoundError(f"Script not found: {path}")
    return path


def resolve_memory_root(vault_dir: Path) -> Path:
    """Return the preferred memory root path, falling back to legacy names."""
    for rel_path in _MEMORY_ROOT_CANDIDATES:
        candidate = vault_dir / rel_path
        if candidate.is_file():
            return candidate
    return vault_dir / _MEMORY_ROOT_CANDIDATES[0]


def is_memory_root_relpath(rel_path: str) -> bool:
    """True when the path is a supported memory-root filename."""
    return rel_path in {path.as_posix() for path in _MEMORY_ROOT_CANDIDATES}


def resolve_decisions_log(vault_dir: Path) -> Path:
    """Return the preferred decisions log path, falling back to legacy names."""
    for rel_path in _DECISIONS_LOG_CANDIDATES:
        candidate = vault_dir / rel_path
        if candidate.is_file():
            return candidate
    return vault_dir / _DECISIONS_LOG_CANDIDATES[0]


def resolve_site_output_dir(vault_dir: Path) -> Path:
    """Prefer Views/site for new projects, but keep legacy Outputs/site working."""
    preferred = vault_dir / "Views" / "site"
    legacy = vault_dir / "Outputs" / "site"
    if preferred.exists() or not legacy.exists():
        return preferred
    return legacy


def resolve_graph_output_dir(vault_dir: Path) -> Path:
    """Prefer Views/graph for new projects, but keep legacy Outputs/graph working."""
    preferred = vault_dir / "Views" / "graph"
    legacy = vault_dir / "Outputs" / "graph"
    if preferred.exists() or not legacy.exists():
        return preferred
    return legacy
