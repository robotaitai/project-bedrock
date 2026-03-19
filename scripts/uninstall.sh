#!/bin/bash
#
# Remove symlinked cursor rules from a project.
#
# Usage:
#   ./uninstall.sh /path/to/project
#

set -euo pipefail

TARGET_PROJECT="${1:-.}"
TARGET_PROJECT="$(cd "$TARGET_PROJECT" && pwd)"
TARGET_DIR="$TARGET_PROJECT/.cursor/rules"

if [ ! -d "$TARGET_DIR" ]; then
    echo "No .cursor/rules/ in $TARGET_PROJECT"
    exit 0
fi

echo "Removing symlinked rules from: $TARGET_PROJECT"
echo ""

for link in "$TARGET_DIR"/*.mdc; do
    [ -L "$link" ] || continue
    name="$(basename "$link")"
    rm "$link"
    echo "  ✗ $name"
done

echo ""
echo "Done. Project-local (non-symlinked) rules were left untouched."
