#!/usr/bin/env bash
set -euo pipefail
root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd -- "$root"

usage() {
    cat <<'HELP'
Usage: ./run.sh PROGRAM [--demo]
       ./run.sh pipe_file [filename]

ID   PROGRAM                Practical
1    address_book           Address book in Bash
2a   fork_sort              Sort in child and parent processes
2b   zombie                 Observe a zombie for 5 seconds, then reap it
2c   orphan                 Observe a child after its parent exits
3    producer_consumer      Bounded buffer with semaphores and a mutex
4    dining_philosophers    Deadlock prevention with an N-1 room semaphore
5    bankers                Banker's safety algorithm
6    fifo                   Two-process sentence statistics using named pipes
7    pipe_file              Parent/child file transfer using two pipes
8a   sstf                   Shortest seek time first
8b   scan                   SCAN, initially toward higher track numbers
8c   clook                  C-LOOK, initially toward higher track numbers

Use --demo to supply sample input. Without --demo, enter your own input.
Examples: ./run.sh 5 --demo
          ./run.sh bankers
          ./run.sh pipe_file "my file.txt"
HELP
}

case "${1:---help}" in
    -h|--help|--list) usage; exit 0 ;;
    1|address_book) program=address_book ;;
    2a|fork_sort) program=fork_sort ;;
    2b|zombie) program=zombie ;;
    2c|orphan) program=orphan ;;
    3|producer_consumer) program=producer_consumer ;;
    4|dining_philosophers) program=dining_philosophers ;;
    5|bankers) program=bankers ;;
    6|fifo) program=fifo ;;
    7|pipe_file) program=pipe_file ;;
    8a|sstf) program=sstf ;;
    8b|scan) program=scan ;;
    8c|clook) program=clook ;;
    *) usage >&2; exit 2 ;;
esac
shift
demo=false
if [[ ${1:-} == --demo ]]; then
    demo=true
    shift
fi
if [[ $# -gt 0 && ( "$program" != pipe_file || $# -ne 1 || "$demo" == true ) ]]; then
    usage >&2
    exit 2
fi

if [[ "$program" == address_book ]]; then
    if "$demo"; then
        book=$(mktemp "${TMPDIR:-/tmp}/oslab-addressbook.XXXXXX")
        trap 'rm -f -- "$book"' EXIT
        ADDRESSBOOK="$book" bash 01-shell/address_book.sh < samples/address-book.in
        exit 0
    fi
    exec bash 01-shell/address_book.sh
fi
if ! command -v make >/dev/null || ! command -v cc >/dev/null; then
    echo 'Install a C compiler and make. See README.md for setup commands.' >&2
    exit 1
fi
if [[ "$program" == fifo ]]; then
    make -s build/process1 build/process2
    if "$demo"; then
        exec bash 06-ipc/run_fifo.sh < samples/sentence.in
    fi
    exec bash 06-ipc/run_fifo.sh
fi
make -s "build/$program"
if "$demo"; then
    case "$program" in
        fork_sort) exec "build/$program" < samples/sort.in ;;
        bankers) exec "build/$program" < samples/bankers.in ;;
        sstf|scan|clook) exec "build/$program" < samples/disk.in ;;
        pipe_file) exec build/pipe_file samples/sample.txt ;;
    esac
fi
exec "build/$program" "$@"
