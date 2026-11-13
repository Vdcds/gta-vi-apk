CC = cc
CFLAGS = -std=c11 -Wall -Wextra -Wpedantic -O2 -D_POSIX_C_SOURCE=200809L

PROGRAMS = fork_sort zombie orphan producer_consumer dining_philosophers bankers process1 process2 pipe_file sstf scan clook
BINARIES = $(addprefix build/,$(PROGRAMS))

.PHONY: all clean test
all: $(BINARIES)

build:
	mkdir -p build

build/fork_sort: 02-process/fork_sort.c common/input.h | build
	$(CC) $(CFLAGS) $< -o $@

build/zombie: 02-process/zombie.c | build
	$(CC) $(CFLAGS) $< -o $@

build/orphan: 02-process/orphan.c | build
	$(CC) $(CFLAGS) $< -o $@

build/producer_consumer: 03-threads/producer_consumer.c common/sync.h | build
	$(CC) $(CFLAGS) $< -o $@ -pthread

build/dining_philosophers: 04-deadlock-handling/dining_philosophers.c common/sync.h | build
	$(CC) $(CFLAGS) $< -o $@ -pthread

build/bankers: 05-deadlock-avoidance/bankers.c common/input.h | build
	$(CC) $(CFLAGS) $< -o $@

build/process1: 06-ipc/process1.c common/io.h | build
	$(CC) $(CFLAGS) $< -o $@

build/process2: 06-ipc/process2.c common/io.h | build
	$(CC) $(CFLAGS) $< -o $@

build/pipe_file: 07-pipes/pipe_file.c common/io.h | build
	$(CC) $(CFLAGS) $< -o $@

build/sstf: 08-disk/sstf.c 08-disk/disk.h common/input.h | build
	$(CC) $(CFLAGS) $< -o $@

build/scan: 08-disk/scan.c 08-disk/disk.h common/input.h | build
	$(CC) $(CFLAGS) $< -o $@

build/clook: 08-disk/clook.c 08-disk/disk.h common/input.h | build
	$(CC) $(CFLAGS) $< -o $@

test: all
	python3 scripts/check.py

clean:
	rm -rf build
