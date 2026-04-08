#!/bin/bash
#
# Collect project evidence into agent-knowledge/Evidence/raw/ and imports/.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=/dev/null
. "$SCRIPT_DIR/lib/knowledge-common.sh"

usage() {
    cat <<'EOF'
Usage:
  scripts/import-agent-history.sh [project-dir]
  scripts/import-agent-history.sh --project <dir> [--dry-run] [--json] [--summary-file <file>]
EOF
}

TARGET_PROJECT_ARG="."
POSITIONAL=()
GENERATED=()
RAW_GENERATED=()
IMPORT_GENERATED=()
WARNINGS=()
DATE="$(kc_today)"

while [ "$#" -gt 0 ]; do
    if kc_parse_common_flag "$@" ; then
        shift
        continue
    fi
    flag_status=$?
    if [ "$flag_status" -eq 2 ]; then
        shift 2
        continue
    fi

    case "$1" in
        --project)
            TARGET_PROJECT_ARG="${2:-.}"
            shift 2
            ;;
        *)
            POSITIONAL+=("$1")
            shift
            ;;
    esac
done

if [ "$SHOW_HELP" -eq 1 ]; then
    usage
    exit 0
fi

if [ ${#POSITIONAL[@]} -ge 1 ]; then
    TARGET_PROJECT_ARG="${POSITIONAL[0]}"
fi

kc_load_project_context "$TARGET_PROJECT_ARG"
kc_require_knowledge_pointer
kc_ensure_dir "$EVIDENCE_RAW_DIR" "agent-knowledge/Evidence/raw"
kc_ensure_dir "$EVIDENCE_IMPORTS_DIR" "agent-knowledge/Evidence/imports"

PROJECT_LABEL="$(basename "$TARGET_PROJECT")"

header() {
    local title="$1"
    local confidence="$2"
    printf '# Evidence: %s\n' "$title"
    printf '# Extracted: %s\n' "$DATE"
    printf '# Project: %s\n' "$PROJECT_LABEL"
    printf '# Confidence: %s\n\n' "$confidence"
}

relative_path() {
    sed "s|$TARGET_PROJECT/||" | sed "s|^$TARGET_PROJECT$|.|"
}

apply_capture() {
    local tmp_file="$1"
    local dst="$2"
    local label="$3"
    local bucket="$4"

    kc_apply_temp_file "$tmp_file" "$dst" "$label"
    case "$KC_LAST_ACTION" in
        created|updated|would-create|would-update)
            GENERATED+=("$label")
            if [ "$bucket" = "raw" ]; then
                RAW_GENERATED+=("$label")
            else
                IMPORT_GENERATED+=("$label")
            fi
            ;;
    esac
}

capture_block() {
    local dst="$1"
    local label="$2"
    local bucket="$3"
    local tmp_file

    tmp_file="$(mktemp)"
    cat > "$tmp_file"
    apply_capture "$tmp_file" "$dst" "$label" "$bucket"
}

kc_log "Collecting evidence: $PROJECT_LABEL"
kc_log ""

if kc_git_available; then
    if kc_git_has_commits; then
        capture_block "$EVIDENCE_RAW_DIR/git-log.txt" "agent-knowledge/Evidence/raw/git-log.txt" "raw" <<EOF
$(header "git-log (oneline, last 300)" "high")
$(git -C "$TARGET_PROJECT" log --oneline -300)
EOF

        capture_block "$EVIDENCE_RAW_DIR/git-log-detail.txt" "agent-knowledge/Evidence/raw/git-log-detail.txt" "raw" <<EOF
$(header "git-log-detail (last 50, with body)" "high")
$(git -C "$TARGET_PROJECT" log -50 --pretty=format:"----%ncommit %h%nDate:   %ai%nAuthor: %an%n%n%s%n%b")
EOF

        capture_block "$EVIDENCE_RAW_DIR/git-authors.txt" "agent-knowledge/Evidence/raw/git-authors.txt" "raw" <<EOF
$(header "git-authors" "high")
$(git -C "$TARGET_PROJECT" log --pretty=format:"%an <%ae>" | sort -u)
EOF
    else
        WARNINGS+=("git evidence skipped because the repository has no commits yet")
        kc_log "  note: git evidence skipped (repository has no commits yet)"
    fi
else
    WARNINGS+=("git evidence skipped because the target is not a git repo")
    kc_log "  note: git evidence skipped (not a git repo)"
fi

capture_block "$EVIDENCE_RAW_DIR/structure.txt" "agent-knowledge/Evidence/raw/structure.txt" "raw" <<EOF
$(header "structure (depth 4)" "high")
$(find "$TARGET_PROJECT" \
    -maxdepth 4 \
    -not -path "*/.git/*" \
    -not -path "*/node_modules/*" \
    -not -path "*/vendor/*" \
    -not -path "*/__pycache__/*" \
    -not -path "*/.venv/*" \
    -not -path "*/dist/*" \
    -not -path "*/.next/*" \
    -not -path "*/build/*" \
    | sort | relative_path)
EOF

capture_block "$EVIDENCE_RAW_DIR/manifests.txt" "agent-knowledge/Evidence/raw/manifests.txt" "raw" <<EOF
$(header "manifests" "high")
$(MANIFESTS="package.json package-lock.json pnpm-lock.yaml yarn.lock pnpm-workspace.yaml nx.json turbo.json pyproject.toml requirements.txt setup.py setup.cfg Pipfile poetry.lock Cargo.toml Cargo.lock go.mod go.sum CMakeLists.txt Makefile package.xml"
found=0
for f in $MANIFESTS; do
    if [ -f "$TARGET_PROJECT/$f" ]; then
        echo "=== $f ==="
        if [ "$(wc -l < "$TARGET_PROJECT/$f")" -gt 200 ]; then
            head -60 "$TARGET_PROJECT/$f"
            echo "... (truncated at 60 lines)"
        else
            cat "$TARGET_PROJECT/$f"
        fi
        echo ""
        found=1
    fi
done
[ "$found" -eq 0 ] && echo "(no manifests found)")
EOF

capture_block "$EVIDENCE_RAW_DIR/config-files.txt" "agent-knowledge/Evidence/raw/config-files.txt" "raw" <<EOF
$(header "config-files" "medium")
$(find "$TARGET_PROJECT" -maxdepth 2 \( \
    -name ".editorconfig" -o \
    -name ".clang-format" -o \
    -name ".clang-tidy" -o \
    -name ".eslintrc" -o \
    -name ".eslintrc.js" -o \
    -name ".eslintrc.cjs" -o \
    -name "eslint.config.js" -o \
    -name "eslint.config.mjs" -o \
    -name "eslint.config.cjs" -o \
    -name ".prettierrc" -o \
    -name ".prettierrc.json" -o \
    -name ".prettierrc.yaml" -o \
    -name ".pre-commit-config.yaml" -o \
    -name "pytest.ini" -o \
    -name "mypy.ini" -o \
    -name "ruff.toml" -o \
    -name "tsconfig.json" -o \
    -name "tsconfig.base.json" \) 2>/dev/null | sort | relative_path)
EOF

capture_block "$EVIDENCE_RAW_DIR/tests.txt" "agent-knowledge/Evidence/raw/tests.txt" "raw" <<EOF
$(header "tests" "medium")
$(find "$TARGET_PROJECT" -maxdepth 3 -type d \( \
    -name "test" -o \
    -name "tests" -o \
    -name "__tests__" -o \
    -name "spec" -o \
    -name "specs" -o \
    -name "integration-tests" -o \
    -name "launch" -o \
    -name "simulation" \) 2>/dev/null | sort | relative_path)
EOF

capture_block "$EVIDENCE_RAW_DIR/ci-workflows.txt" "agent-knowledge/Evidence/raw/ci-workflows.txt" "raw" <<EOF
$(header "ci-workflows" "medium")
$(if [ -d "$TARGET_PROJECT/.github/workflows" ]; then
    for f in "$TARGET_PROJECT/.github/workflows"/*.yml "$TARGET_PROJECT/.github/workflows"/*.yaml; do
        [ -f "$f" ] || continue
        echo "=== .github/workflows/$(basename "$f") ==="
        if [ "$(wc -l < "$f")" -gt 150 ]; then
            head -60 "$f"
            echo "... (truncated)"
        else
            cat "$f"
        fi
        echo ""
    done
else
    echo "(no .github/workflows found)"
fi)
EOF

capture_block "$EVIDENCE_IMPORTS_DIR/existing-docs.txt" "agent-knowledge/Evidence/imports/existing-docs.txt" "imports" <<EOF
$(header "existing-docs" "medium")
$(DOC_FILES="README.md README.rst CLAUDE.md AGENTS.md .agent-project.yaml .cursorrules agent-knowledge/INDEX.md agent-knowledge/STATUS.md agent-knowledge/Memory/MEMORY.md docs/README.md"
found=0
for f in $DOC_FILES; do
    fp="$TARGET_PROJECT/$f"
    if [ -f "$fp" ]; then
        echo "=== $f ==="
        if [ "$(wc -l < "$fp")" -gt 300 ]; then
            head -100 "$fp"
            echo "... (truncated at 100 lines)"
        else
            cat "$fp"
        fi
        echo ""
        found=1
    fi
done
[ "$found" -eq 0 ] && echo "(no key doc files found)")
EOF

capture_block "$EVIDENCE_IMPORTS_DIR/doc-index.txt" "agent-knowledge/Evidence/imports/doc-index.txt" "imports" <<EOF
$(header "doc-index (paths)" "medium")
$(find "$TARGET_PROJECT" \
    -name "*.md" \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/vendor/*" \
    | sort | relative_path)
EOF

capture_block "$EVIDENCE_IMPORTS_DIR/tasks.txt" "agent-knowledge/Evidence/imports/tasks.txt" "imports" <<EOF
$(header "tasks" "medium")
$(TASK_FILES="tasks/todo.md tasks/lessons.md tasks/plan.md"
found=0
for f in $TASK_FILES; do
    fp="$TARGET_PROJECT/$f"
    if [ -f "$fp" ]; then
        echo "=== $f ==="
        cat "$fp"
        echo ""
        found=1
    fi
done
if [ -d "$TARGET_PROJECT/tasks" ]; then
    echo "=== tasks/ contents ==="
    ls "$TARGET_PROJECT/tasks/"
    found=1
fi
[ "$found" -eq 0 ] && echo "(no tasks/ directory found)")
EOF

capture_block "$EVIDENCE_IMPORTS_DIR/session-files.txt" "agent-knowledge/Evidence/imports/session-files.txt" "imports" <<EOF
$(header "session-files" "low")
$(if [ -d "$SESSIONS_DIR" ]; then
    find "$SESSIONS_DIR" -mindepth 1 -maxdepth 1 -type f | sort | while read -r f; do
        [ -n "$f" ] || continue
        echo "=== ${f#$TARGET_PROJECT/} ==="
        if [ "$(wc -l < "$f")" -gt 120 ]; then
            head -60 "$f"
            echo "... (truncated at 60 lines)"
        else
            cat "$f"
        fi
        echo ""
    done
else
    echo "(no local Sessions/ directory found)"
fi)
EOF

capture_block "$EVIDENCE_IMPORTS_DIR/cursor-sessions.txt" "agent-knowledge/Evidence/imports/cursor-sessions.txt" "imports" <<EOF
$(header "cursor-sessions" "low")
$(found=""
for d in "$HOME"/.cursor/projects/*/sessions; do
    if [ -d "$d" ] && printf '%s' "$d" | grep -qi "$PROJECT_LABEL" 2>/dev/null; then
        echo "=== $d ==="
        ls -lt "$d" 2>/dev/null | head -10
        echo ""
        found="yes"
    fi
done
[ -z "$found" ] && echo "(no matching Cursor session dirs found)")
EOF

capture_block "$EVIDENCE_IMPORTS_DIR/trace-index.txt" "agent-knowledge/Evidence/imports/trace-index.txt" "imports" <<EOF
$(header "trace-index" "low")
$(TRACE_DIRS="agent-traces traces logs/agent agent-knowledge/Outputs/traces"
found=0
for d in $TRACE_DIRS; do
    if [ -d "$TARGET_PROJECT/$d" ]; then
        echo "=== $d ==="
        find "$TARGET_PROJECT/$d" -type f | sort | relative_path
        echo ""
        found=1
    fi
done
[ "$found" -eq 0 ] && echo "(no imported trace directories found)")
EOF

kc_status_load
if [ "${DRY_RUN:-0}" -eq 0 ] && [ ${#GENERATED[@]} -gt 0 ]; then
    STATUS_LAST_IMPORT="$(kc_now_utc)"
fi
STATUS_WARNING_LINES="$(printf '%s\n' "${WARNINGS[@]+"${WARNINGS[@]}"}")"
kc_status_write

json_summary="{"
json_summary="$json_summary\"script\":\"import-agent-history\","
json_summary="$json_summary\"project_root\":\"$(kc_json_escape "$TARGET_PROJECT")\","
json_summary="$json_summary\"dry_run\":$(kc_json_bool "$DRY_RUN"),"
json_summary="$json_summary\"raw_files\":$(kc_json_array "${RAW_GENERATED[@]+"${RAW_GENERATED[@]}"}"),"
json_summary="$json_summary\"import_files\":$(kc_json_array "${IMPORT_GENERATED[@]+"${IMPORT_GENERATED[@]}"}"),"
json_summary="$json_summary\"warnings\":$(kc_json_array "${WARNINGS[@]+"${WARNINGS[@]}"}")"
json_summary="$json_summary}"
kc_write_json_output "$json_summary"

if [ "$JSON_MODE" -ne 1 ]; then
    kc_log ""
    kc_log "Evidence collected in:"
    kc_log "  agent-knowledge/Evidence/raw/"
    kc_log "  agent-knowledge/Evidence/imports/"
    kc_log ""
    kc_log "Curated memory remains separate. Review evidence before writing durable notes."
fi
