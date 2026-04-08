#!/bin/bash

# Shared helpers for the operational knowledge scripts.
# Bash 3 compatible.

DRY_RUN="${DRY_RUN:-0}"
JSON_MODE="${JSON_MODE:-0}"
FORCE="${FORCE:-0}"
SUMMARY_FILE="${SUMMARY_FILE:-}"
SHOW_HELP="${SHOW_HELP:-0}"

KC_LAST_ACTION=""

kc_now_utc() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

kc_today() {
    date +"%Y-%m-%d"
}

kc_log() {
    if [ "${JSON_MODE:-0}" -ne 1 ]; then
        printf '%s\n' "$*"
    fi
}

kc_err() {
    printf '%s\n' "$*" >&2
}

kc_fail() {
    kc_err "$*"
    exit 1
}

kc_parse_common_flag() {
    case "${1:-}" in
        --dry-run)
            DRY_RUN=1
            return 0
            ;;
        --json)
            JSON_MODE=1
            return 0
            ;;
        --summary-file)
            SUMMARY_FILE="${2:-}"
            return 2
            ;;
        --force)
            FORCE=1
            return 0
            ;;
        --help|-h)
            SHOW_HELP=1
            return 0
            ;;
    esac
    return 1
}

kc_json_escape() {
    local value="${1:-}"
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/\\r}
    value=${value//$'\t'/\\t}
    printf '%s' "$value"
}

kc_json_bool() {
    if [ "${1:-0}" -eq 1 ] 2>/dev/null; then
        printf 'true'
    else
        printf 'false'
    fi
}

kc_json_array() {
    local first=1
    local item=""
    printf '['
    for item in "$@"; do
        if [ $first -eq 0 ]; then
            printf ','
        fi
        first=0
        printf '"%s"' "$(kc_json_escape "$item")"
    done
    printf ']'
}

kc_json_array_from_lines() {
    local text="${1:-}"
    local items=()
    local line=""

    while IFS= read -r line; do
        [ -n "$line" ] || continue
        items+=("$line")
    done <<EOF
$text
EOF

    kc_json_array "${items[@]}"
}

kc_write_json_output() {
    local json="$1"

    if [ -n "${SUMMARY_FILE:-}" ]; then
        printf '%s\n' "$json" > "$SUMMARY_FILE"
    fi

    if [ "${JSON_MODE:-0}" -eq 1 ]; then
        printf '%s\n' "$json"
    fi
}

kc_resolve_relative() {
    local base="$1"
    local path_value="$2"

    case "$path_value" in
        "")
            return 1
            ;;
        /*)
            printf '%s\n' "$path_value"
            ;;
        ~/*)
            printf '%s\n' "$HOME/${path_value#~/}"
            ;;
        *)
            (
                cd "$base" 2>/dev/null && printf '%s/%s\n' "$(pwd)" "$path_value"
            )
            ;;
    esac
}

kc_yaml_leaf_value() {
    local file="$1"
    local key="$2"

    awk -v key="$key" '
        $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
            value = $0
            sub("^[[:space:]]*" key ":[[:space:]]*", "", value)
            gsub(/^["'"'"']|["'"'"']$/, "", value)
            print value
            exit
        }
    ' "$file" 2>/dev/null
}

kc_slugify() {
    printf '%s' "$1" \
        | tr '[:upper:]' '[:lower:]' \
        | sed 's/[^a-z0-9]/-/g' \
        | sed 's/-\{2,\}/-/g' \
        | sed 's/^-//' \
        | sed 's/-$//'
}

kc_ensure_dir() {
    local dir="$1"
    local label="${2:-$1}"

    if [ -d "$dir" ]; then
        KC_LAST_ACTION="unchanged"
        return 0
    fi

    if [ "${DRY_RUN:-0}" -eq 1 ]; then
        kc_log "  would create dir: $label"
        KC_LAST_ACTION="would-create"
        return 0
    fi

    mkdir -p "$dir"
    kc_log "  created dir: $label"
    KC_LAST_ACTION="created"
}

kc_apply_temp_file() {
    local tmp_file="$1"
    local dst="$2"
    local label="${3:-$2}"
    local existed=0

    if [ -e "$dst" ]; then
        existed=1
    fi

    if [ "$existed" -eq 1 ] && cmp -s "$tmp_file" "$dst"; then
        rm -f "$tmp_file"
        KC_LAST_ACTION="unchanged"
        return 0
    fi

    if [ "${DRY_RUN:-0}" -eq 1 ]; then
        if [ "$existed" -eq 1 ]; then
            kc_log "  would update: $label"
            KC_LAST_ACTION="would-update"
        else
            kc_log "  would create: $label"
            KC_LAST_ACTION="would-create"
        fi
        rm -f "$tmp_file"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    cp "$tmp_file" "$dst"
    rm -f "$tmp_file"

    if [ "$existed" -eq 1 ]; then
        kc_log "  updated: $label"
        KC_LAST_ACTION="updated"
    else
        kc_log "  created: $label"
        KC_LAST_ACTION="created"
    fi
}

kc_write_text_file() {
    local dst="$1"
    local label="${2:-$1}"
    local tmp_file

    tmp_file="$(mktemp)"
    cat > "$tmp_file"
    kc_apply_temp_file "$tmp_file" "$dst" "$label"
}

kc_copy_file() {
    local src="$1"
    local dst="$2"
    local label="${3:-$2}"
    local tmp_file

    tmp_file="$(mktemp)"
    cat "$src" > "$tmp_file"
    kc_apply_temp_file "$tmp_file" "$dst" "$label"
}

kc_replace_in_template() {
    local src="$1"
    local dst="$2"
    local label="$3"
    shift 3

    local tmp_file
    local expr=()
    local pair=""
    local key=""
    local value=""

    tmp_file="$(mktemp)"
    while [ "$#" -gt 1 ]; do
        key="$1"
        value="$2"
        expr+=("-e" "s|$key|$value|g")
        shift 2
    done

    sed "${expr[@]}" "$src" > "$tmp_file"
    kc_apply_temp_file "$tmp_file" "$dst" "$label"
}

kc_ensure_symlink() {
    local target="$1"
    local link_path="$2"
    local label="${3:-$2}"
    local current_target=""

    if [ -L "$link_path" ]; then
        current_target="$(readlink "$link_path" 2>/dev/null || true)"
        if [ "$current_target" = "$target" ]; then
            KC_LAST_ACTION="unchanged"
            return 0
        fi
    elif [ -e "$link_path" ]; then
        kc_fail "Refusing to replace non-symlink path: $link_path"
    fi

    if [ "${DRY_RUN:-0}" -eq 1 ]; then
        kc_log "  would link: $label -> $target"
        if [ -L "$link_path" ]; then
            KC_LAST_ACTION="would-update"
        else
            KC_LAST_ACTION="would-create"
        fi
        return 0
    fi

    mkdir -p "$(dirname "$link_path")"
    ln -sfn "$target" "$link_path"
    kc_log "  linked: $label -> $target"
    if [ -L "$link_path" ]; then
        KC_LAST_ACTION="updated"
    else
        KC_LAST_ACTION="created"
    fi
}

kc_detect_symlink_caveat() {
    case "$(uname -s 2>/dev/null || echo unknown)" in
        MINGW*|MSYS*|CYGWIN*)
            printf '%s\n' "Windows environments may require Developer Mode or administrator rights for symlinks. If link creation fails, use a junction or run the shell with elevated permissions."
            ;;
        *)
            printf '%s\n' ""
            ;;
    esac
}

kc_load_project_context() {
    local project_dir="${1:-.}"
    local pointer_value=""
    local real_value=""

    TARGET_PROJECT="$(cd "$project_dir" 2>/dev/null && pwd)"
    [ -n "$TARGET_PROJECT" ] || kc_fail "Unable to resolve project dir: $project_dir"

    PROJECT_NAME="$(basename "$TARGET_PROJECT")"
    PROJECT_SLUG="$(kc_slugify "$PROJECT_NAME")"
    PROJECT_PROFILE="unknown"
    AGENT_PROJECT_FILE="$TARGET_PROJECT/.agent-project.yaml"
    POINTER_PATH="$TARGET_PROJECT/agent-knowledge"
    POINTER_DISPLAY="./agent-knowledge"
    FRAMEWORK_REPO=""

    if [ -f "$AGENT_PROJECT_FILE" ]; then
        PROJECT_NAME="$(kc_yaml_leaf_value "$AGENT_PROJECT_FILE" "name" || printf '%s' "$PROJECT_NAME")"
        PROJECT_SLUG="$(kc_yaml_leaf_value "$AGENT_PROJECT_FILE" "slug" || printf '%s' "$PROJECT_SLUG")"
        PROJECT_PROFILE="$(kc_yaml_leaf_value "$AGENT_PROJECT_FILE" "profile" || printf 'unknown')"
        FRAMEWORK_REPO="$(kc_yaml_leaf_value "$AGENT_PROJECT_FILE" "repo" || true)"
        pointer_value="$(kc_yaml_leaf_value "$AGENT_PROJECT_FILE" "pointer_path" || true)"
        real_value="$(kc_yaml_leaf_value "$AGENT_PROJECT_FILE" "real_path" || true)"
        if [ -n "$pointer_value" ]; then
            POINTER_DISPLAY="$pointer_value"
            POINTER_PATH="$(kc_resolve_relative "$TARGET_PROJECT" "$pointer_value")"
        fi
    fi

    if [ -n "$real_value" ]; then
        KNOWLEDGE_REAL_DIR="$(kc_resolve_relative "$TARGET_PROJECT" "$real_value")"
        if [ -d "$KNOWLEDGE_REAL_DIR" ]; then
            KNOWLEDGE_REAL_DIR="$(cd "$KNOWLEDGE_REAL_DIR" 2>/dev/null && pwd -P)"
        fi
    elif [ -d "$POINTER_PATH" ]; then
        KNOWLEDGE_REAL_DIR="$(cd "$POINTER_PATH" 2>/dev/null && pwd -P)"
    else
        KNOWLEDGE_REAL_DIR="$POINTER_PATH"
    fi

    KNOWLEDGE_POINTER_PATH="$POINTER_PATH"
    KNOWLEDGE_DIR="$POINTER_PATH"
    MEMORY_DIR="$KNOWLEDGE_DIR/Memory"
    MEMORY_ROOT="$MEMORY_DIR/MEMORY.md"
    DECISIONS_DIR="$MEMORY_DIR/decisions"
    EVIDENCE_DIR="$KNOWLEDGE_DIR/Evidence"
    EVIDENCE_RAW_DIR="$EVIDENCE_DIR/raw"
    EVIDENCE_IMPORTS_DIR="$EVIDENCE_DIR/imports"
    EVIDENCE_TOOLING_DIR="$EVIDENCE_DIR/tooling"
    SESSIONS_DIR="$KNOWLEDGE_DIR/Sessions"
    OUTPUTS_DIR="$KNOWLEDGE_DIR/Outputs"
    DASHBOARDS_DIR="$KNOWLEDGE_DIR/Dashboards"
    LOCAL_TEMPLATES_DIR="$KNOWLEDGE_DIR/Templates"
    OBSIDIAN_DIR="$KNOWLEDGE_DIR/.obsidian"
    STATUS_FILE="$KNOWLEDGE_DIR/STATUS.md"
}

kc_is_windows_like() {
    case "$(uname -s 2>/dev/null || echo unknown)" in
        MINGW*|MSYS*|CYGWIN*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

kc_pointer_resolved_path() {
    [ -d "$KNOWLEDGE_POINTER_PATH" ] || return 1
    (
        cd "$KNOWLEDGE_POINTER_PATH" 2>/dev/null && pwd -P
    )
}

kc_rel_knowledge_path() {
    local path="$1"

    case "$path" in
        "$KNOWLEDGE_DIR"/*)
            printf '%s\n' "${path#$KNOWLEDGE_DIR/}"
            ;;
        "$KNOWLEDGE_REAL_DIR"/*)
            printf '%s\n' "${path#$KNOWLEDGE_REAL_DIR/}"
            ;;
        *)
            printf '%s\n' "$path"
            ;;
    esac
}

kc_require_project_metadata() {
    [ -f "$AGENT_PROJECT_FILE" ] || kc_fail "Missing $AGENT_PROJECT_FILE"
}

kc_require_knowledge_pointer() {
    [ -e "$KNOWLEDGE_POINTER_PATH" ] || kc_fail "Missing local knowledge pointer: $KNOWLEDGE_POINTER_PATH"
    [ -d "$KNOWLEDGE_POINTER_PATH" ] || kc_fail "Local knowledge pointer is not a directory: $KNOWLEDGE_POINTER_PATH"
    pointer_resolved="$(kc_pointer_resolved_path || true)"
    [ -n "$pointer_resolved" ] || kc_fail "Unable to resolve local knowledge pointer: $KNOWLEDGE_POINTER_PATH"
    [ "$pointer_resolved" = "$KNOWLEDGE_REAL_DIR" ] || kc_fail "Local knowledge pointer must resolve to the external knowledge folder: $KNOWLEDGE_REAL_DIR"
    if [ ! -L "$KNOWLEDGE_POINTER_PATH" ] && ! kc_is_windows_like; then
        kc_fail "Local knowledge handle must be a symlink to the external knowledge folder, not a repo-local directory: $KNOWLEDGE_POINTER_PATH"
    fi
}

kc_git_available() {
    git -C "$TARGET_PROJECT" rev-parse --git-dir >/dev/null 2>&1
}

kc_git_has_commits() {
    git -C "$TARGET_PROJECT" rev-parse --verify HEAD >/dev/null 2>&1
}

kc_git_changed_files() {
    if ! kc_git_available; then
        return 0
    fi

    git -C "$TARGET_PROJECT" status --porcelain 2>/dev/null \
        | sed 's/^...//' \
        | sed 's/ -> /\n/' \
        | awk 'NF { print $0 }' \
        | sort -u
}

kc_append_unique_bullet() {
    local file="$1"
    local section="$2"
    local bullet="$3"
    local label="${4:-$file}"
    local tmp_file

    [ -f "$file" ] || return 1

    tmp_file="$(mktemp)"
    awk -v heading="## $section" -v bullet="$bullet" '
        BEGIN {
            in_section = 0
            seen = 0
            inserted = 0
        }
        {
            if (in_section && /^## / && $0 != heading) {
                if (!seen && !inserted) {
                    print bullet
                    inserted = 1
                }
                in_section = 0
            }

            if ($0 == heading) {
                in_section = 1
            }

            if (in_section && $0 == bullet) {
                seen = 1
            }

            print
        }
        END {
            if (in_section && !seen && !inserted) {
                print bullet
            }
        }
    ' "$file" > "$tmp_file"

    kc_apply_temp_file "$tmp_file" "$file" "$label"
}

kc_has_frontmatter() {
    local file="$1"
    head -1 "$file" 2>/dev/null | grep -q '^---$'
}

kc_status_load() {
    STATUS_PROJECT="$PROJECT_NAME"
    STATUS_PROFILE="$PROJECT_PROFILE"
    STATUS_REAL_PATH="$KNOWLEDGE_REAL_DIR"
    STATUS_POINTER_PATH="$POINTER_DISPLAY"
    STATUS_LAST_BOOTSTRAP=""
    STATUS_LAST_IMPORT=""
    STATUS_LAST_PROJECT_SYNC=""
    STATUS_LAST_GLOBAL_SYNC=""
    STATUS_LAST_COMPACTION=""
    STATUS_LAST_VALIDATION=""
    STATUS_LAST_VALIDATION_RESULT="unknown"
    STATUS_LAST_DOCTOR=""
    STATUS_LAST_DOCTOR_RESULT="unknown"
    STATUS_WARNING_LINES=""

    if [ ! -f "$STATUS_FILE" ]; then
        return 0
    fi

    STATUS_PROJECT="$(kc_yaml_leaf_value "$STATUS_FILE" "project" || printf '%s' "$STATUS_PROJECT")"
    STATUS_PROFILE="$(kc_yaml_leaf_value "$STATUS_FILE" "profile" || printf '%s' "$STATUS_PROFILE")"
    STATUS_REAL_PATH="$(kc_yaml_leaf_value "$STATUS_FILE" "real_knowledge_path" || printf '%s' "$STATUS_REAL_PATH")"
    STATUS_POINTER_PATH="$(kc_yaml_leaf_value "$STATUS_FILE" "local_pointer_path" || printf '%s' "$STATUS_POINTER_PATH")"
    STATUS_LAST_BOOTSTRAP="$(kc_yaml_leaf_value "$STATUS_FILE" "last_bootstrap" || true)"
    STATUS_LAST_IMPORT="$(kc_yaml_leaf_value "$STATUS_FILE" "last_backfill_import" || true)"
    STATUS_LAST_PROJECT_SYNC="$(kc_yaml_leaf_value "$STATUS_FILE" "last_project_sync" || true)"
    STATUS_LAST_GLOBAL_SYNC="$(kc_yaml_leaf_value "$STATUS_FILE" "last_global_sync" || true)"
    STATUS_LAST_COMPACTION="$(kc_yaml_leaf_value "$STATUS_FILE" "last_compaction" || true)"
    STATUS_LAST_VALIDATION="$(kc_yaml_leaf_value "$STATUS_FILE" "last_validation" || true)"
    STATUS_LAST_VALIDATION_RESULT="$(kc_yaml_leaf_value "$STATUS_FILE" "last_validation_result" || printf 'unknown')"
    STATUS_LAST_DOCTOR="$(kc_yaml_leaf_value "$STATUS_FILE" "last_doctor" || true)"
    STATUS_LAST_DOCTOR_RESULT="$(kc_yaml_leaf_value "$STATUS_FILE" "last_doctor_result" || printf 'unknown')"
    STATUS_WARNING_LINES="$(
        awk '
            $0 == "## Health Warnings" { in_section = 1; next }
            in_section && /^## / { exit }
            in_section && /^- / { sub(/^- /, "", $0); print }
        ' "$STATUS_FILE" 2>/dev/null
    )"
}

kc_status_write() {
    local tmp_file
    local warnings_text="${1:-$STATUS_WARNING_LINES}"
    local warning=""

    tmp_file="$(mktemp)"
    {
        printf '%s\n' '---'
        printf 'note_type: knowledge-status\n'
        printf 'project: %s\n' "$STATUS_PROJECT"
        printf 'profile: %s\n' "$STATUS_PROFILE"
        printf 'real_knowledge_path: %s\n' "$STATUS_REAL_PATH"
        printf 'local_pointer_path: %s\n' "$STATUS_POINTER_PATH"
        printf 'last_bootstrap: %s\n' "$STATUS_LAST_BOOTSTRAP"
        printf 'last_backfill_import: %s\n' "$STATUS_LAST_IMPORT"
        printf 'last_project_sync: %s\n' "$STATUS_LAST_PROJECT_SYNC"
        printf 'last_global_sync: %s\n' "$STATUS_LAST_GLOBAL_SYNC"
        printf 'last_compaction: %s\n' "$STATUS_LAST_COMPACTION"
        printf 'last_validation: %s\n' "$STATUS_LAST_VALIDATION"
        printf 'last_validation_result: %s\n' "$STATUS_LAST_VALIDATION_RESULT"
        printf 'last_doctor: %s\n' "$STATUS_LAST_DOCTOR"
        printf 'last_doctor_result: %s\n' "$STATUS_LAST_DOCTOR_RESULT"
        printf '%s\n\n' '---'
        printf '# Knowledge Status: %s\n\n' "$STATUS_PROJECT"
        printf '## Current State\n\n'
        printf -- '- Profile: `%s`\n' "$STATUS_PROFILE"
        printf -- '- Real knowledge path: `%s`\n' "$STATUS_REAL_PATH"
        printf -- '- Local pointer path: `%s`\n\n' "$STATUS_POINTER_PATH"
        printf '## Activity\n\n'
        printf -- '- Last bootstrap: `%s`\n' "${STATUS_LAST_BOOTSTRAP:-not-yet}"
        printf -- '- Last backfill/import: `%s`\n' "${STATUS_LAST_IMPORT:-not-yet}"
        printf -- '- Last project sync: `%s`\n' "${STATUS_LAST_PROJECT_SYNC:-not-yet}"
        printf -- '- Last global sync: `%s`\n' "${STATUS_LAST_GLOBAL_SYNC:-not-yet}"
        printf -- '- Last compaction: `%s`\n' "${STATUS_LAST_COMPACTION:-not-yet}"
        printf -- '- Last validation: `%s` (`%s`)\n' "${STATUS_LAST_VALIDATION:-not-yet}" "${STATUS_LAST_VALIDATION_RESULT:-unknown}"
        printf -- '- Last doctor: `%s` (`%s`)\n\n' "${STATUS_LAST_DOCTOR:-not-yet}" "${STATUS_LAST_DOCTOR_RESULT:-unknown}"
        printf '## Health Warnings\n\n'
        if [ -n "$warnings_text" ]; then
            printf '%s\n' "$warnings_text" | while read -r warning; do
                [ -n "$warning" ] || continue
                printf -- '- %s\n' "$warning"
            done
        else
            printf -- '- None.\n'
        fi
    } > "$tmp_file"

    kc_apply_temp_file "$tmp_file" "$STATUS_FILE" "agent-knowledge/STATUS.md"
}

kc_run_shell_command() {
    local label="$1"
    local command="$2"
    local workdir="${3:-$PWD}"
    local tmp_file

    tmp_file="$(mktemp)"
    KC_COMMAND_OUTPUT=""
    KC_COMMAND_STATUS="skipped"

    if [ "${DRY_RUN:-0}" -eq 1 ]; then
        kc_log "  would run [$label]: $command"
        KC_COMMAND_STATUS="dry-run"
        rm -f "$tmp_file"
        return 0
    fi

    if (cd "$workdir" && bash -lc "$command") > "$tmp_file" 2>&1; then
        KC_COMMAND_STATUS="passed"
    else
        KC_COMMAND_STATUS="failed"
    fi
    KC_COMMAND_OUTPUT="$(cat "$tmp_file")"
    rm -f "$tmp_file"

    return 0
}
