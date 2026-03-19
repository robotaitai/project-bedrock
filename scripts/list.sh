#!/bin/bash
#
# List all available cursor rules with their descriptions.
#

RULES_DIR="$(cd "$(dirname "$0")/../rules" && pwd)"

echo "Available cursor rules:"
echo ""

for rule in "$RULES_DIR"/*.mdc; do
    [ -f "$rule" ] || continue
    name="$(basename "$rule")"
    desc=$(grep -m1 "^description:" "$rule" | sed 's/^description: *//')
    printf "  %-45s %s\n" "$name" "$desc"
done
