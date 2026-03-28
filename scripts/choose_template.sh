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

rtrim() {
    local s="$1"
    while [ -n "$s" ] && [ "${s: -1}" = "/" ]; do
        s="${s:0:$((${#s}-1))}"
    done
    printf '%s' "$s"
}

# state
in_programs=0
in_versions=0
root_name=""
root_path=""
prog_name=""
prog_path=""
ver_name=""
ver_path=""
labels=()
paths=()

CHOOSER_DEBUG="${CHOOSER_DEBUG:-}"

# Simple, line-oriented parser using bash regex (pure-bash)
arr_stack=()
while IFS= read -r line; do
    if [ -n "${CHOOSER_DEBUG}" ]; then
        printf 'DBG: LINE: %s\n' "$line" >&2
    fi

    # detect array openings (rough heuristic)
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

    # detect array closing
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

    # capture name
    if [[ $line =~ \"name\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]]; then
        val="${BASH_REMATCH[1]}"
        if (( in_versions > 0 )); then
            ver_name="$val"
        elif (( in_programs > 0 )); then
            prog_name="$val"
        else
            root_name="${root_name:-$val}"
        fi
        # if we've captured a full version, emit
        if [ -n "${ver_name:-}" ] && [ -n "${ver_path:-}" ]; then
            rp="$(rtrim "$root_path")"
            pp="$(rtrim "$prog_path")"
            vp="$(rtrim "$ver_path")"
            outpath=""
            if [ -n "$rp" ]; then outpath="$rp"; fi
            if [ -n "$pp" ]; then outpath="${outpath:+${outpath}/}$pp"; fi
            if [ -n "$vp" ]; then outpath="${outpath:+${outpath}/}$vp"; fi
            while [[ "$outpath" == *"//"* ]]; do outpath="${outpath//\/\//\/}"; done
            outpath="${outpath#/}"
            labels+=("$root_name / $prog_name / $ver_name")
            paths+=("$outpath")
            ver_name=""
            ver_path=""
        fi
        continue
    fi

    # capture path
    if [[ $line =~ \"path\"[[:space:]]*:[[:space:]]*\"([^\"]*)\" ]]; then
        val="${BASH_REMATCH[1]}"
        if (( in_versions > 0 )); then
            ver_path="$val"
        elif (( in_programs > 0 )); then
            prog_path="$val"
        else
            root_path="${root_path:-$val}"
        fi
        # if we've captured a full version, emit
        if [ -n "${ver_name:-}" ] && [ -n "${ver_path:-}" ]; then
            rp="$(rtrim "$root_path")"
            pp="$(rtrim "$prog_path")"
            vp="$(rtrim "$ver_path")"
            outpath=""
            if [ -n "$rp" ]; then outpath="$rp"; fi
            if [ -n "$pp" ]; then outpath="${outpath:+${outpath}/}$pp"; fi
            if [ -n "$vp" ]; then outpath="${outpath:+${outpath}/}$vp"; fi
            while [[ "$outpath" == *"//"* ]]; do outpath="${outpath//\/\//\/}"; done
            outpath="${outpath#/}"
            labels+=("$root_name / $prog_name / $ver_name")
            paths+=("$outpath")
            ver_name=""
            ver_path=""
        fi
        continue
    fi

done < "$json_file"

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
