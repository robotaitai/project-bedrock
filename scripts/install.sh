#!/bin/bash
#
# Install cursor rules into a project by symlinking from this repo.
#
# Usage:
#   ./install.sh /path/to/project          # install all rules
#   ./install.sh /path/to/project rule.mdc  # install one rule
#   ./install.sh .                          # install into cwd
#

set -euo pipefail

RULES_DIR="$(cd "$(dirname "$0")/../rules" && pwd)"
TARGET_PROJECT="${1:-.}"
SPECIFIC_RULE="${2:-}"

# Resolve target
TARGET_PROJECT="$(cd "$TARGET_PROJECT" && pwd)"
TARGET_DIR="$TARGET_PROJECT/.cursor/rules"

mkdir -p "$TARGET_DIR"

link_rule() {
    local src="$1"
    local name="$(basename "$src")"
    local dst="$TARGET_DIR/$name"

    if [ -L "$dst" ]; then
        echo "  ↻ $name (already linked)"
    elif [ -f "$dst" ]; then
        echo "  ⚠ $name (exists as file, skipping — remove manually to link)"
    else
        ln -s "$src" "$dst"
        echo "  ✓ $name"
    fi
}

echo "Installing cursor rules into: $TARGET_PROJECT"
echo ""

if [ -n "$SPECIFIC_RULE" ]; then
    if [ -f "$RULES_DIR/$SPECIFIC_RULE" ]; then
        link_rule "$RULES_DIR/$SPECIFIC_RULE"
    else
        echo "Rule not found: $SPECIFIC_RULE"
        echo "Available rules:"
        ls "$RULES_DIR"/*.mdc 2>/dev/null | xargs -I{} basename {}
        exit 1
    fi
else
    for rule in "$RULES_DIR"/*.mdc; do
        [ -f "$rule" ] && link_rule "$rule"
    done
fi

echo ""
echo "Done. Rules are symlinked — edits in ~/cursor-rules propagate everywhere."
