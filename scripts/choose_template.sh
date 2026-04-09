#!/usr/bin/env bash

set -euo pipefail

# locate templates.json by walking up from the script dir / PWD
find_templates_json() {
    local script dir script_dir
    script="${BASH_SOURCE[0]}"
    if [[ "$script" == */* ]]; then
        script_dir="$(cd "${script%/*}" && pwd)"
    else
        script_dir="$(pwd)"
    fi
    if [ -f "$script_dir/../templates.json" ]; then
        printf '%s' "$script_dir/../templates.json"
        return 0
    fi
    if [ -f "$PWD/templates.json" ]; then
        printf '%s' "$PWD/templates.json"
        return 0
    fi
    dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/templates.json" ]; then
            printf '%s' "$dir/templates.json"
            return 0
        fi
        dir="$(cd "$dir/.." && pwd)"
    done
    return 1
}

json_file="$(find_templates_json 2>/dev/null)" || { echo "templates.json not found" >&2; exit 2; }

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required to parse templates.json but was not found." >&2
    exit 2
fi

# Parse templates.json with Python — outputs "label<TAB>path" lines.
_PY_PARSE='
import json, sys

def strip(s):
    return s.strip("/")

with open(sys.argv[1]) as f:
    data = json.load(f)

root_path = strip(data.get("path", ""))
root_name = data.get("name", "")
for prog in data.get("programs", []):
    pp = strip(prog.get("path", ""))
    pn = prog.get("name", "")
    for ver in prog.get("versions", []):
        vp = strip(ver.get("path", ""))
        vn = ver.get("name", "")
        full_path = "/".join(p for p in [root_path, pp, vp] if p)
        label = " / ".join(p for p in [root_name, pn, vn] if p)
        print(f"{label}\t{full_path}")
'

labels=()
paths=()
while IFS=$'\t' read -r _label _path; do
    labels+=("$_label")
    paths+=("$_path")
done < <(python3 -c "$_PY_PARSE" "$json_file")

if [ ${#labels[@]} -eq 0 ]; then
    echo "No templates found in $json_file" >&2
    exit 4
fi

# If non-interactive, return first path (useful for curl | bash callers)
if [ ! -t 0 ] || [ ! -t 1 ]; then
    first_path="${paths[0]}"
    if [ -n "${CHOOSER_OUTPUT:-}" ]; then
        printf '%s\n' "$first_path" > "$CHOOSER_OUTPUT"
    else
        printf '%s\n' "$first_path"
    fi
    exit 0
fi

# Use fzf if available (interactive only)
if command -v fzf >/dev/null 2>&1 && [ -t 0 ]; then
    selected_line=$(for idx in "${!labels[@]}"; do printf '%s\t%s\n' "${labels[idx]}" "${paths[idx]}"; done | fzf --delimiter=$'\t' --with-nth=1 --height=40% --reverse --prompt="Search template> ") || true
    if [ -n "${selected_line:-}" ]; then
        # extract path after tab
        selected_path="${selected_line#*$'\t'}"
        if [ -n "${CHOOSER_OUTPUT:-}" ]; then
            printf '%s\n' "$selected_path" > "$CHOOSER_OUTPUT"
        else
            printf '%s\n' "$selected_path"
        fi
        exit 0
    fi
    # if fzf cancelled or not selected, fallthrough to other methods
fi

# Incremental, line-based fuzzy search in pure bash
inc_search() {
    local prompt="Search template (press enter to choose first match)> "
    local query
    local -a matches_idx

    while true; do
        printf '%s' "$prompt"
        if ! IFS= read -r query; then
            return 1
        fi
        matches_idx=()
        local li=0
        local lower_q lower_lbl
        lower_q="${query,,}"
        for i in "${!labels[@]}"; do
            lower_lbl="${labels[i],,}"
            # use subsequence fuzzy match (osi -> bOlSAs matches)
            if [[ -z "$lower_q" ]]; then
                ok=0
            else
                ok=1
            fi
            if [ $ok -ne 0 ]; then
                # check subsequence: each char of lower_q appears in order in lower_lbl
                hay="$lower_lbl"
                ok=1
                for ((k=0;k<${#lower_q};k++)); do
                    ch="${lower_q:k:1}"
                    if [[ "$hay" == *"$ch"* ]]; then
                        hay="${hay#*$ch}"
                    else
                        ok=0
                        break
                    fi
                done
            fi
            if [ "$ok" -eq 1 ]; then
                matches_idx+=("$i")
                printf ' %2d) %s\n' $((li+1)) "${labels[i]}"
                li=$((li+1))
                if [ $li -ge 10 ]; then break; fi
            fi
        done
        if [ ${#matches_idx[@]} -eq 0 ]; then
            printf ' (no matches)\n'
            continue
        fi
        sel_index=${matches_idx[0]}
        if [ -n "${CHOOSER_OUTPUT:-}" ]; then
            printf '%s\n' "${paths[sel_index]}" > "$CHOOSER_OUTPUT"
        else
            printf '%s\n' "${paths[sel_index]}"
        fi
        return 0
    done
}

if inc_search; then
    exit 0
fi

# Fallback numbered selection
printf '\nAvailable templates (from templates.json):\n'
declare -A idx2path=()
i=1
for idx in "${!labels[@]}"; do
    label="${labels[idx]}"
    path="${paths[idx]}"
    printf ' %2d) %s\n' "$i" "$label"
    idx2path[$i]="$path"
    i=$((i+1))
done

while true; do
    read -r -p "Enter template number (q to quit, default 1): " sel
    sel="${sel:-1}"
    if [[ "$sel" =~ ^[qQ]$ ]]; then
        exit 5
    fi
    if [[ "$sel" =~ ^[0-9]+$ ]] && [ -n "${idx2path[$sel]+_}" ]; then
        if [ -n "${CHOOSER_OUTPUT:-}" ]; then
            printf '%s\n' "${idx2path[$sel]}" > "$CHOOSER_OUTPUT"
        else
            printf '%s\n' "${idx2path[$sel]}"
        fi
        exit 0
    fi
    echo "Invalid selection."
done
