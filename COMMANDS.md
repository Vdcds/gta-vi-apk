# Compile and run each program directly

Run these commands from the repository root after installing the tools listed in [README.md](README.md).

Create the output directory once:

```bash
mkdir -p build
```

## 1. Shell programming

```bash
bash 01-shell/address_book.sh
```

## 2. Process management

Compile and run parent and child sorting:

```bash
cc -std=c11 -Wall -Wextra 02-process/fork_sort.c -o build/fork_sort
./build/fork_sort < samples/sort.in
```

Compile and run the zombie demo:

```bash
cc -std=c11 -Wall -Wextra 02-process/zombie.c -o build/zombie
./build/zombie
```

During the five-second pause, run the printed `ps` command in another terminal.

Compile and run the orphan demo:

```bash
cc -std=c11 -Wall -Wextra 02-process/orphan.c -o build/orphan
./build/orphan
```

Wait two seconds for the child to print its new parent PID.

## 3. Thread synchronization

```bash
cc -std=c11 -Wall -Wextra 03-threads/producer_consumer.c -o build/producer_consumer -pthread
./build/producer_consumer
```

## 4. Deadlock handling

```bash
cc -std=c11 -Wall -Wextra 04-deadlock-handling/dining_philosophers.c -o build/dining_philosophers -pthread
./build/dining_philosophers
```

## 5. Deadlock avoidance

```bash
cc -std=c11 -Wall -Wextra 05-deadlock-avoidance/bankers.c -o build/bankers
./build/bankers < samples/bankers.in
```

## 6. Inter-process communication

Compile both processes and start them together:

```bash
cc -std=c11 -Wall -Wextra 06-ipc/process1.c -o build/process1
cc -std=c11 -Wall -Wextra 06-ipc/process2.c -o build/process2
bash 06-ipc/run_fifo.sh
```

Enter a sentence. To print the saved counts:

```bash
cat build/fifo-result.txt
```

To observe the processes in separate terminals, first create a directory and FIFOs from the repository root in Terminal 1:

```bash
mkdir -p build/manual-fifo
cd build/manual-fifo
mkfifo fifo1 fifo2
../process2
```

From the repository root in Terminal 2:

```bash
cd build/manual-fifo
../process1
```

Enter a sentence in Terminal 2. After both programs exit, clean up from either terminal:

```bash
cat result.txt
rm fifo1 fifo2
```

## 7. Full duplex communication using two pipes

```bash
cc -std=c11 -Wall -Wextra 07-pipes/pipe_file.c -o build/pipe_file
./build/pipe_file samples/sample.txt
```

To enter a path at the prompt:

```bash
./build/pipe_file
```

## 8. Disk scheduling

Compile and run SSTF:

```bash
cc -std=c11 -Wall -Wextra 08-disk/sstf.c -o build/sstf
./build/sstf < samples/disk.in
```

Compile and run SCAN:

```bash
cc -std=c11 -Wall -Wextra 08-disk/scan.c -o build/scan
./build/scan < samples/disk.in
```

Compile and run C-LOOK:

```bash
cc -std=c11 -Wall -Wextra 08-disk/clook.c -o build/clook
./build/clook < samples/disk.in
```

Remove the `< samples/...` part from a command to enter your own input.
