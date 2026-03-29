#!/usr/bin/env bash

set -euo pipefail

confirm() {
    local prompt default reply
    prompt="$1"
    default="${2:-Y}"

    if [ -t 0 ]; then
        if [ "$default" = "Y" ] || [ "$default" = "y" ]; then
            read -r -p "$prompt [Y/n] " reply
            reply="${reply:-Y}"
        else
            read -r -p "$prompt [y/N] " reply
            reply="${reply:-N}"
        fi
        case "$reply" in
            [Yy]*) return 0 ;;
            *) return 1 ;;
        esac
    else
        # not interactive: use default
        if [ "$default" = "Y" ] || [ "$default" = "y" ]; then
            return 0
        else
            return 1
        fi
    fi
}

# Global state for pipe-mode helpers
_INSTALL_TMPDIR=""
_SCRIPTS_DIR=""

# Resolve the directory containing install.sh's sibling scripts and set
# _SCRIPTS_DIR.  Do NOT call this in a subshell — it sets global variables
# and registers a cleanup trap.
# When run via `bash <(curl ...)` BASH_SOURCE[0] is a /proc/self/fd path,
# not a real file; in that case we download the helpers from GitHub.
_resolve_scripts_dir() {
    local src="${BASH_SOURCE[0]:-$0}"
    if [[ -f "$src" && "$src" != /proc/self/fd/* && "$src" != /dev/stdin ]]; then
        _SCRIPTS_DIR="$(cd "$(dirname "$src")" && pwd)"
        return 0
    fi
    # Running via pipe / process substitution — download helpers to a temp dir.
    if [ -n "${_INSTALL_TMPDIR:-}" ]; then
        _SCRIPTS_DIR="$_INSTALL_TMPDIR/scripts"
        return 0
    fi
    _INSTALL_TMPDIR="$(mktemp -d)"
    trap 'rm -rf "$_INSTALL_TMPDIR"' EXIT INT TERM
    local base="${TEXACADEMY_RAW_BASE:-https://raw.githubusercontent.com/PepeuFBV/texacademy/main}"
    mkdir -p "$_INSTALL_TMPDIR/scripts"
    curl -fsSL "$base/scripts/choose_template.sh" -o "$_INSTALL_TMPDIR/scripts/choose_template.sh"
    curl -fsSL "$base/templates.json" -o "$_INSTALL_TMPDIR/templates.json"
    chmod +x "$_INSTALL_TMPDIR/scripts/choose_template.sh"
    _SCRIPTS_DIR="$_INSTALL_TMPDIR/scripts"
}

chooseTemplate() {
    local template_dir="$1"
    local chooser selected
    _resolve_scripts_dir
    chooser="$_SCRIPTS_DIR/choose_template.sh"
    if [ -x "$chooser" ]; then
        selected="$("$chooser")" || return $?
        printf '%s\n' "$selected"
        return 0
    elif [ -f "$chooser" ]; then
        selected="$(bash "$chooser")" || return $?
        printf '%s\n' "$selected"
        return 0
    else
        echo "Error: chooser script not found: $chooser" >&2
        return 1
    fi
}

install_fzf() {
    # no-op if already installed
    if command -v fzf >/dev/null 2>&1; then
        echo "fzf already installed"
        return 0
    fi

    # prefer non-root git-based install (works in CI/devcontainer without sudo)
    if command -v git >/dev/null 2>&1; then
        if [ ! -d "$HOME/.fzf" ]; then
            if git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"; then
                if [ -x "$HOME/.fzf/install" ]; then
                    # run non-interactive installer
                    "$HOME/.fzf/install" --all >/dev/null 2>&1 || true
                fi
            fi
        else
            if [ -x "$HOME/.fzf/install" ]; then
                "$HOME/.fzf/install" --all >/dev/null 2>&1 || true
            fi
        fi
        # ensure fzf binary is on PATH for current shell
        if [ -x "$HOME/.fzf/bin/fzf" ]; then
            export PATH="$HOME/.fzf/bin:$PATH"
            command -v fzf >/dev/null 2>&1 && return 0
        fi
    fi

    # fall back to package manager install (may require sudo)
    local SUDO=""
    if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    fi

    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update && $SUDO apt-get install -y fzf
        return $?
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y fzf
        return $?
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -Sy --noconfirm fzf
        return $?
    elif command -v apk >/dev/null 2>&1; then
        $SUDO apk add --no-cache fzf
        return $?
    elif command -v brew >/dev/null 2>&1; then
        brew install fzf
        return $?
    fi

    return 1
}

# interactive cli options
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # interactive cli options
    if [ -t 0 ]; then
        echo "====================="
        echo "TexAcademy Installer"
        echo "===================="
    else
        echo "Installing complete setup automatically..."
    fi

    # optionally install fzf for improved fuzzy search
    if [ -t 0 ]; then
        if confirm "Install fzf for improved fuzzy search? (recommended)" N; then
            if install_fzf; then
                echo "fzf installed or already available"
            else
                echo "fzf installation failed or not available; continuing with built-in chooser" >&2
            fi
        fi
    fi

    # first, choose template (interactive fuzzy search)
    _resolve_scripts_dir
    script_dir="$_SCRIPTS_DIR"
    tmpfile="$(mktemp)"
    CHOOSER_OUTPUT="$tmpfile" bash "$script_dir/choose_template.sh" || { echo "Template selection aborted or failed." >&2; rm -f "$tmpfile"; exit 1; }
    selected_template="$(<"$tmpfile")"
    rm -f "$tmpfile"

    # then ask about devcontainer setup
    install_devontainer=$(confirm "Install Devcontainer setup for development?" Y)

    echo "$selected_template"
fi