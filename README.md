# Cursor Rules

Personal collection of [Cursor](https://cursor.sh) rules (`.mdc` files) that provide persistent AI guidance across projects.

## Structure

```
cursor-rules/
├── rules/                    # All .mdc rule files
│   └── generate-architecture-doc.mdc
├── scripts/
│   ├── install.sh            # Symlink rules into a project
│   ├── uninstall.sh          # Remove symlinks from a project
│   └── list.sh               # List available rules
└── README.md
```

## Usage

### Install rules into a project

```bash
# Install all rules into a project (creates symlinks)
~/cursor-rules/scripts/install.sh /path/to/project

# Install a specific rule
~/cursor-rules/scripts/install.sh /path/to/project generate-architecture-doc.mdc

# Install into current directory
~/cursor-rules/scripts/install.sh .
```

### List available rules

```bash
~/cursor-rules/scripts/list.sh
```

### Remove rules from a project

```bash
~/cursor-rules/scripts/uninstall.sh /path/to/project
```

## How it works

Rules are **symlinked** into each project's `.cursor/rules/` directory. This means:

- Editing a rule in `~/cursor-rules/rules/` updates it everywhere
- Each project sees the rules as local files
- Project-specific rules (non-symlinked) are left untouched
- Add `!.cursor/rules/` to your project's `.gitignore` if you don't want symlinks committed

## Adding a new rule

1. Create a `.mdc` file in `rules/` with the required frontmatter:

```markdown
---
description: What this rule does (shown in Cursor's rule picker)
globs:                    # Optional: file patterns to trigger on
alwaysApply: false        # true = always active, false = manual or glob-triggered
---

# Rule content here
```

2. Run `install.sh` on your projects to pick it up.

## Tip: shell alias

Add to `~/.bashrc`:

```bash
alias cursor-rules-install='~/cursor-rules/scripts/install.sh'
alias cursor-rules-list='~/cursor-rules/scripts/list.sh'
```
