#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

desktop=${OSLAB_DESKTOP_DIR:-}
if [[ -z "$desktop" ]] && command -v xdg-user-dir >/dev/null; then
    desktop=$(xdg-user-dir DESKTOP) || desktop=''
fi
# Some headless systems disable the Desktop by mapping it to the home folder.
if [[ -z "$desktop" || "$desktop" == "$HOME" ]]; then
    desktop="$HOME/Desktop"
fi
mkdir -p -- "$desktop"
desktop=$(cd -- "$desktop" && pwd -P)

if [[ "$root" == "$desktop" || $(dirname -- "$root") == "$desktop" ]]; then
    project=$root
else
    case "$desktop/" in
        "$root/"*)
            echo 'Choose a Desktop folder outside the source project.' >&2
            exit 1
            ;;
    esac
    project="$desktop/gta-vi-apk"
    if [[ -e "$project" ]]; then
        # A new directory preserves edits in earlier Desktop copies.
        project=$(mktemp -d "$desktop/gta-vi-apk.XXXXXX")
    else
        mkdir -- "$project"
    fi
    tar -C "$root" --exclude='./.git' --exclude='./build' \
        --exclude='./addressbook.txt' --exclude='./.DS_Store' -cf - . |
        tar -C "$project" -xf -
fi
printf 'Desktop project: %s\n' "$project"

if ! command -v code >/dev/null; then
    printf '\nVS Code is missing. Your Desktop copy is ready.\n'
    printf 'Install VS Code, then run this launcher again:\n\n'
    printf '  sudo snap install code --classic\n\n'
    printf 'Read %s/cheats/00-UBUNTU-START.txt for setup help.\n' "$project"
    exit 1
fi
code --new-window "$project" "$project/cheats/00-UBUNTU-START.txt"
exec bash "$project/scripts/menu.sh"
