# gta-vi-apk

Operating systems lab programs from the eight attached practical files. Includes 13 runnable Bash and C programs, sample input, and commands for every practical.

The original text files are preserved unchanged in [`originals/`](originals/). Runnable source files are in the numbered practical folders.

## Start on Ubuntu

Open a terminal in the extracted or cloned project folder and run:

```bash
bash UBUNTU-START.sh
```

The launcher copies the project to your Ubuntu Desktop, opens it in VS Code, and starts the practical menu. Choose an ID to open its source and `.txt` explanation, then press Enter for sample input. Programs compile and run directly on Ubuntu. Existing Desktop copies and edits are preserved.

Install the compiler and VS Code once using [`cheats/00-UBUNTU-START.txt`](cheats/00-UBUNTU-START.txt). The launcher finds localized Desktop folders through `xdg-user-dir`. In VS Code, **Ctrl+Shift+B** runs the same menu in the integrated terminal. For a terminal-only session, run `bash scripts/menu.sh` from the project folder.

## Start on Windows

Download the ZIP from **Code > Download ZIP**, extract it, then double-click `WINDOWS-START.cmd`.

The launcher copies the project to your Windows Desktop, opens the Desktop copy in VS Code, and starts a practical menu through WSL Ubuntu. Choose an ID to open its source and `.txt` cheat sheet, then press Enter to run with sample input. Existing Desktop copies are kept. A project already on the Desktop runs from that folder.

Install WSL Ubuntu, its C compiler, and VS Code once using [`cheats/00-WINDOWS-START.txt`](cheats/00-WINDOWS-START.txt). In VS Code, **Ctrl+Shift+B** also opens the menu in the integrated terminal. The run menu and generated programs use the Desktop copy.

Each practical has a [plain-text cheat sheet](cheats/) with direct commands, an explanation, expected output, and viva notes. Source files, headers, and sample inputs stay together so every program can compile after copying.

## Get the programs

```bash
git clone https://github.com/Vdcds/gta-vi-apk.git
cd gta-vi-apk
```

Use Linux, macOS, or Ubuntu inside Windows WSL. Install Bash, a C compiler, and Make.

On Ubuntu, Debian, or Ubuntu in WSL:

```bash
sudo apt update
sudo apt install -y build-essential git python3
```

On macOS, install the command line tools if `cc` or `make` is missing:

```bash
xcode-select --install
```

Python 3 is needed only for `make test`.

## Run any practical

Run commands from this repository's folder. The launcher compiles the selected C program automatically.

| Practical | Program | Run with your own input | Run with sample input |
| --- | --- | --- | --- |
| 1 | Bash address book | `./run.sh 1` | `./run.sh 1 --demo` |
| 2a | Parent and child sorting | `./run.sh 2a` | `./run.sh 2a --demo` |
| 2b | Zombie process | `./run.sh 2b` | Same command; no input needed |
| 2c | Orphan process | `./run.sh 2c` | Same command; no input needed |
| 3 | Producer and consumer | `./run.sh 3` | Same command; no input needed |
| 4 | Dining philosophers | `./run.sh 4` | Same command; no input needed |
| 5 | Banker's algorithm | `./run.sh 5` | `./run.sh 5 --demo` |
| 6 | FIFO sentence statistics | `./run.sh 6` | `./run.sh 6 --demo` |
| 7 | File transfer using pipes | `./run.sh 7` | `./run.sh 7 --demo` |
| 8a | SSTF disk scheduling | `./run.sh 8a` | `./run.sh 8a --demo` |
| 8b | SCAN disk scheduling | `./run.sh 8b` | `./run.sh 8b --demo` |
| 8c | C-LOOK disk scheduling | `./run.sh 8c` | `./run.sh 8c --demo` |

Program names also work. For example:

```bash
./run.sh bankers --demo
./run.sh producer_consumer
./run.sh pipe_file "samples/sample.txt"
./run.sh --list
```

To compile and run each source file yourself, use [the direct commands](COMMANDS.md).

## Enter input

### Address book

Choose a menu option, then enter the requested fields. Records stay in `addressbook.txt`. Use option 6 to exit.

To choose another data file:

```bash
ADDRESSBOOK=my-contacts.txt ./run.sh 1
```

The sample demo uses a temporary address book and removes it when finished.

### Process management

For sorting, enter the element count followed by the integers. [The sorting sample](samples/sort.in) sorts to `10 20 30 40 50` in both processes.

The zombie demo prints a `ps` command. Run that command in another terminal during the five-second pause to see `Z` in the process status. The parent then reaps the child.

The orphan demo prints the child's new parent PID after two seconds. That PID depends on your operating system or container. The shell prompt can return before the child prints.

### Thread synchronization and deadlock handling

The producer generates `10, 20, ..., 100`. The consumer reads those ten items in order through a buffer of size 5.

Each of the five philosophers eats three meals, then exits. Thread output order can change between runs.

### Banker's algorithm

Enter the process count, resource-type count, allocation matrix, maximum matrix, and available resources, in that order. Matrix rows represent processes. Columns represent resource types.

To use the supplied practical's data:

```bash
./run.sh bankers < samples/bankers.in
```

The result is a safe state with sequence `P0 -> P2 -> P3 -> P4 -> P1`.

### Inter-process communication

Enter a sentence of up to 499 characters. The launcher creates two FIFOs in a temporary directory and starts both C programs. Process 2 writes the counts to a file and sends them to Process 1. The launcher saves a copy in `build/fifo-result.txt` and removes the temporary FIFOs.

```bash
./run.sh fifo --demo
cat build/fifo-result.txt
```

The sample returns 39 characters, 4 words, and 1 line. Character counts are byte counts. The Enter key's newline is removed before counting. An empty sentence has 0 lines.

### Pipes between parent and child

Enter a filename at the prompt, or pass the path directly:

```bash
./run.sh pipe_file samples/sample.txt
```

The parent sends the filename through one pipe. The child streams the file back through a second pipe. Paths with spaces and files larger than 4096 bytes work.

### Disk scheduling

Enter the request count, request queue, and initial head position, in that order. Tracks range from 0 to 199.

```bash
./run.sh sstf < samples/disk.in
./run.sh scan < samples/disk.in
./run.sh clook < samples/disk.in
```

For the sample, total head movements are 248 for SSTF, 280 for SCAN, and 322 for C-LOOK. SCAN moves toward higher tracks, reaches 199, then reverses to serve lower requests. C-LOOK moves upward, then wraps to the lowest pending request. Its wrap movement counts toward the total. Average seek length is total head movement divided by request count.

## Build or check all programs

```bash
make
make test
```

The checks run all 13 programs and check process states, synchronization output, safe and unsafe resource states, FIFO counts, large file transfer, disk seek sequences, the practical menu, and the Ubuntu Desktop launcher. Editor commands use a test substitute during automated checks. GitHub Actions runs these checks on Linux and macOS, and checks the Desktop copy logic and PowerShell syntax on Windows.

To remove compiled programs and generated FIFO results:

```bash
make clean
```

The runnable versions split combined examples into separate files, validate numeric input, fix SCAN serving requests twice, and make the philosopher demo finish. The thread demos use POSIX named semaphores because macOS does not support `sem_init`. Semaphore names are removed immediately after creation.
