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
        # Not interactive: use default
        if [ "$default" = "Y" ] || [ "$default" = "y" ]; then
            return 0
        else
            return 1
        fi
    fi
}

chooseTemplate() {
    local template_dir="$1"
    local script_dir chooser selected
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    chooser="$script_dir/choose_template.sh"
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
    # No-op if already installed
    if command -v fzf >/dev/null 2>&1; then
        echo "fzf already installed"
        return 0
    fi

    # Prefer non-root git-based install (works in CI/devcontainer without sudo)
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

    # Optionally install fzf for improved fuzzy search
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
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    tmpfile="$(mktemp)"
    CHOOSER_OUTPUT="$tmpfile" bash "$script_dir/choose_template.sh" || { echo "Template selection aborted or failed." >&2; rm -f "$tmpfile"; exit 1; }
    selected_template="$(<"$tmpfile")"
    rm -f "$tmpfile"

    # then ask about devcontainer setup
    install_devontainer=$(confirm "Install Devcontainer setup for development?" Y)

    echo "$selected_template"
fi