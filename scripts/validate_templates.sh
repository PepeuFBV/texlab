#!/usr/bin/env bash
# validate_templates.sh — checks consistency between templates.json and templates/ directory.
#
# Two checks:
#   1. Every path declared in templates.json exists as a directory with a main.tex.
#   2. Every directory under templates/ that contains main.tex is declared in templates.json.
#
# Exit code 0 = all OK, 1 = at least one error found.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
JSON_FILE="$REPO_ROOT/templates.json"
TEMPLATES_DIR="$REPO_ROOT/templates"

errors=0

# -----------------------------------------------------------------------
# 1. Parse templates.json and collect all declared leaf paths
# -----------------------------------------------------------------------
in_programs=0
in_versions=0
root_path=""
prog_path=""
ver_path=""
arr_stack=()
declared_paths=()

while IFS= read -r line; do
    if [[ "$line" == *'"programs"'* && "$line" == *'['* ]]; then
        arr_stack+=("programs")
        in_programs=$((in_programs+1))
        continue
    fi
    if [[ "$line" == *'"versions"'* && "$line" == *'['* ]]; then
        arr_stack+=("versions")
        in_versions=$((in_versions+1))
        continue
    fi
    if [[ "$line" == *']'* ]]; then
        if (( ${#arr_stack[@]} > 0 )); then
            last_idx=$(( ${#arr_stack[@]} - 1 ))
            arrkey="${arr_stack[$last_idx]}"
            unset 'arr_stack[$last_idx]'
            arr_stack=( "${arr_stack[@]}" )
            if [ "$arrkey" = "programs" ]; then in_programs=$((in_programs-1)); fi
            if [ "$arrkey" = "versions" ]; then in_versions=$((in_versions-1)); fi
        fi
        continue
    fi
    if [[ $line =~ \"path\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]]; then
        val="${BASH_REMATCH[1]%/}"
        if (( in_versions > 0 )); then
            ver_path="$val"
        elif (( in_programs > 0 )); then
            prog_path="$val"
        else
            root_path="${root_path:-$val}"
        fi
        if [ -n "${root_path:-}" ] && [ -n "${prog_path:-}" ] && [ -n "${ver_path:-}" ]; then
            declared_paths+=("$root_path/$prog_path/$ver_path")
            ver_path=""
        fi
    fi
done < "$JSON_FILE"

if [ ${#declared_paths[@]} -eq 0 ]; then
    echo "ERROR: No paths found in templates.json" >&2
    exit 1
fi

# -----------------------------------------------------------------------
# 2. Check every declared path exists as a directory containing main.tex
# -----------------------------------------------------------------------
echo "=== Checking declared paths exist under templates/ ==="
for path in "${declared_paths[@]}"; do
    full="$TEMPLATES_DIR/$path"
    if [ ! -d "$full" ]; then
        echo "  FAIL – missing directory:  templates/$path"
        errors=$((errors+1))
    elif [ ! -f "$full/main.tex" ]; then
        echo "  FAIL – missing main.tex:   templates/$path"
        errors=$((errors+1))
    else
        echo "  OK   templates/$path"
    fi
done

# -----------------------------------------------------------------------
# 3. Check every main.tex-containing dir is declared in templates.json
# -----------------------------------------------------------------------
echo ""
echo "=== Checking all template directories are declared in templates.json ==="
while IFS= read -r mainfile; do
    dir="$(dirname "$mainfile")"
    rel="${dir#"$TEMPLATES_DIR/"}"
    found=0
    for p in "${declared_paths[@]}"; do
        if [ "$p" = "$rel" ]; then
            found=1
            break
        fi
    done
    if [ "$found" -eq 0 ]; then
        echo "  FAIL – undeclared dir:     templates/$rel (has main.tex but no entry in templates.json)"
        errors=$((errors+1))
    else
        echo "  OK   templates/$rel"
    fi
done < <(find "$TEMPLATES_DIR" -name "main.tex" ! -path "*/.git/*" | sort)

echo ""
if [ "$errors" -gt 0 ]; then
    echo "FAILED: $errors error(s) found." >&2
    exit 1
else
    echo "All template checks passed."
fi
