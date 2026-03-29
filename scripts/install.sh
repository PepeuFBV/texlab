#!/usr/bin/env bash

set -euo pipefail

confirm() {
    local prompt default reply
    prompt="$1"
    default="${2:-Y}"

    if [ -t 0 ]; then
        # interactive TTY: show prompt with default hint
        if [ "$default" = "Y" ] || [ "$default" = "y" ]; then
            read -r -p "$prompt [Y/n] " reply
            reply="${reply:-Y}"
        else
            read -r -p "$prompt [y/N] " reply
            reply="${reply:-N}"
        fi
    else
        # piped stdin or EOF: read silently, use default if empty or EOF
        if IFS= read -r reply; then
            reply="${reply:-$default}"
        else
            reply="$default"
        fi
    fi

    case "$reply" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

_INSTALL_TMPDIR=""
_SCRIPTS_DIR=""
_REPO_ROOT=""   # local clone root OR extracted archive root (pipe mode)

_resolve_scripts_dir() {
    local src="${BASH_SOURCE[0]:-$0}"
    if [[ -f "$src" && "$src" != /proc/self/fd/* && "$src" != /dev/stdin ]]; then
        _SCRIPTS_DIR="$(cd "$(dirname "$src")" && pwd)"
        _REPO_ROOT="$(cd "$_SCRIPTS_DIR/.." && pwd)"
        return 0
    fi
    # pipe / process-substitution mode — bootstrap into a temp dir.
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

_ensure_repo_root() {
    [ -n "${_REPO_ROOT:-}" ] && return 0
    local ref="${TEXACADEMY_REF:-main}"
    local archive="$_INSTALL_TMPDIR/repo.tar.gz"
    local archive_url="${TEXACADEMY_ARCHIVE_URL:-https://github.com/PepeuFBV/texacademy/archive/refs/heads/${ref}.tar.gz}"
    echo "Downloading template files..."
    curl -fsSL "$archive_url" -o "$archive"
    mkdir -p "$_INSTALL_TMPDIR/repo"
    tar -xzf "$archive" -C "$_INSTALL_TMPDIR/repo" --strip-components=1
    _REPO_ROOT="$_INSTALL_TMPDIR/repo"
}

install_fzf() {
    if command -v fzf >/dev/null 2>&1; then
        echo "fzf is already installed."
        return 0
    fi

    echo "Installing fzf..."

    # prefer non-root git-based install (works in CI/devcontainer without sudo)
    if command -v git >/dev/null 2>&1; then
        if [ ! -d "$HOME/.fzf" ]; then
            git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf" >/dev/null 2>&1
        fi
        if [ -x "$HOME/.fzf/install" ]; then
            "$HOME/.fzf/install" --all >/dev/null 2>&1 || true
        fi
        if [ -x "$HOME/.fzf/bin/fzf" ]; then
            export PATH="$HOME/.fzf/bin:$PATH"
        fi
        command -v fzf >/dev/null 2>&1 && { echo "fzf installed successfully."; return 0; }
    fi

    # package manager fallback (may require sudo)
    local SUDO=""
    if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
        SUDO="sudo"
    fi

    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update -qq && $SUDO apt-get install -y -qq fzf
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y fzf
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -Sy --noconfirm fzf
    elif command -v apk >/dev/null 2>&1; then
        $SUDO apk add --no-cache fzf
    elif command -v brew >/dev/null 2>&1; then
        brew install fzf
    else
        echo "Error: could not find a supported package manager to install fzf." >&2
        return 1
    fi

    command -v fzf >/dev/null 2>&1 && { echo "fzf installed successfully."; return 0; }
    echo "Error: fzf installation failed." >&2
    return 1
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "====================="
    echo "TexAcademy Installer"
    echo "===================="

    install_fzf

    _resolve_scripts_dir

    tmpfile="$(mktemp)"
    CHOOSER_OUTPUT="$tmpfile" bash "$_SCRIPTS_DIR/choose_template.sh" \
        || { echo "Template selection aborted or failed." >&2; rm -f "$tmpfile"; exit 1; }
    selected_template="$(<"$tmpfile")"
    rm -f "$tmpfile"

    read -r -p "Enter your paper name (used as the project directory name): " paper_name
    paper_name="${paper_name#"${paper_name%%[![:space:]]*}"}"  # ltrim
    paper_name="${paper_name%"${paper_name##*[![:space:]]}"}"  # rtrim
    if [ -z "$paper_name" ]; then
        echo "Error: paper name cannot be empty." >&2
        exit 1
    fi
    paper_dir="$PWD/$paper_name"
    if [ -e "$paper_dir" ]; then
        echo "Error: '$paper_dir' already exists." >&2
        exit 1
    fi

    if confirm "Install Devcontainer setup for VS Code?" Y; then
        want_devcontainer=1
    else
        want_devcontainer=0
    fi

    _ensure_repo_root

    mkdir -p "$paper_dir"
    cp -r "$_REPO_ROOT/templates/$selected_template/." "$paper_dir/"
    echo "Template '$selected_template' installed to: $paper_dir"

    if [ "$want_devcontainer" -eq 1 ]; then
        cp -r "$_REPO_ROOT/.devcontainer" "$paper_dir/.devcontainer"
        echo "Devcontainer setup installed to: $paper_dir/.devcontainer"
    fi

    echo ""
    echo "Done! Your project is ready at: $paper_dir"
fi
