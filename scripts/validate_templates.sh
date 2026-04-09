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

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to parse templates.json but was not found." >&2
    exit 2
fi

errors=0

# -----------------------------------------------------------------------
# 1. Parse templates.json and collect all declared leaf paths using Python
# -----------------------------------------------------------------------
_PY_PATHS='
import json, sys

def strip(s):
    return s.strip("/")

with open(sys.argv[1]) as f:
    data = json.load(f)

root_path = strip(data.get("path", ""))
for prog in data.get("programs", []):
    pp = strip(prog.get("path", ""))
    for ver in prog.get("versions", []):
        vp = strip(ver.get("path", ""))
        print("/".join(p for p in [root_path, pp, vp] if p))
'

mapfile -t declared_paths < <(python3 -c "$_PY_PATHS" "$JSON_FILE")

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
