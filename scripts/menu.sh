#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd -- "$root"

if ! command -v cc >/dev/null || ! command -v make >/dev/null; then
    cat <<'SETUP'
Install the compiler inside Ubuntu once:

  sudo apt update
  sudo apt install -y build-essential

Then restart UBUNTU-START.sh on Ubuntu or WINDOWS-START.cmd on Windows.
Read cheats/00-UBUNTU-START.txt or cheats/00-WINDOWS-START.txt for setup.
SETUP
    exit 1
fi

while true; do
    printf '\nDesktop project: %s\n\n' "$root"
    bash run.sh --list
    printf '\nEnter a practical ID, or q to quit.\n'
    IFS= read -r -p 'Practical: ' practical || exit 0
    case "$practical" in
        q|Q) exit 0 ;;
        1) sheet=01-SHELL.txt; sources=(01-shell/address_book.sh) ;;
        2a) sheet=02-PROCESSES.txt; sources=(02-process/fork_sort.c) ;;
        2b) sheet=02-PROCESSES.txt; sources=(02-process/zombie.c) ;;
        2c) sheet=02-PROCESSES.txt; sources=(02-process/orphan.c) ;;
        3) sheet=03-THREADS.txt; sources=(03-threads/producer_consumer.c) ;;
        4) sheet=04-DEADLOCK-HANDLING.txt; sources=(04-deadlock-handling/dining_philosophers.c) ;;
        5) sheet=05-BANKERS.txt; sources=(05-deadlock-avoidance/bankers.c) ;;
        6) sheet=06-FIFO-IPC.txt; sources=(06-ipc/process1.c 06-ipc/process2.c) ;;
        7) sheet=07-PIPES.txt; sources=(07-pipes/pipe_file.c) ;;
        8a) sheet=08-DISK-SCHEDULING.txt; sources=(08-disk/sstf.c) ;;
        8b) sheet=08-DISK-SCHEDULING.txt; sources=(08-disk/scan.c) ;;
        8c) sheet=08-DISK-SCHEDULING.txt; sources=(08-disk/clook.c) ;;
        *) echo 'Choose an ID from the list.'; continue ;;
    esac
    printf '\n'
    cat "cheats/$sheet"
    printf '\n'
    # The same command opens source and notes in native Ubuntu or WSL VS Code.
    if [[ ${OSLAB_SKIP_EDITOR:-0} != 1 ]] && command -v code >/dev/null; then
        code --reuse-window "$root" "${sources[@]}" "$root/cheats/$sheet" || true
    fi
    IFS= read -r -p 'Use sample input? [Y/n]: ' mode || exit 0
    arguments=("$practical")
    case "$mode" in
        n|N) ;;
        *) arguments+=(--demo) ;;
    esac
    printf '\nRunning: bash run.sh'
    printf ' %q' "${arguments[@]}"
    printf '\n\n'
    if bash run.sh "${arguments[@]}"; then
        echo 'Program finished.'
    else
        echo 'Program returned an error. Read the message above and try again.'
    fi
    # orphan.c returns in the parent before its child prints two seconds later.
    if [[ "$practical" == 2c ]]; then sleep 3; fi
    printf '\n'
    IFS= read -r -p 'Press Enter to return to the practical menu...' _ || exit 0
done
