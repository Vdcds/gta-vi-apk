#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
work=$(mktemp -d "${TMPDIR:-/tmp}/oslab-fifo.XXXXXX")
worker=''
cleanup() {
    if [[ -n "$worker" ]]; then
        kill "$worker" 2>/dev/null || true
        wait "$worker" 2>/dev/null || true
    fi
    rm -rf -- "$work"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
cd -- "$work"
mkfifo fifo1 fifo2
"$root/build/process2" &
worker=$!
"$root/build/process1"
wait "$worker"
worker=''
cp result.txt "$root/build/fifo-result.txt"
printf '\nResult saved to %s/build/fifo-result.txt\n' "$root"
