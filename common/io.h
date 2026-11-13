#ifndef LAB_IO_H
#define LAB_IO_H

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

static inline void fail(const char *operation)
{
    perror(operation);
    exit(EXIT_FAILURE);
}

static inline void write_all(int fd, const void *data, size_t length)
{
    const char *position = data;
    while (length) {
        ssize_t written = write(fd, position, length);
        if (written == -1 && errno == EINTR)
            continue;
        if (written <= 0)
            fail("write");
        position += written;
        length -= (size_t)written;
    }
}

static inline ssize_t read_some(int fd, void *buffer, size_t capacity)
{
    ssize_t length;
    do {
        length = read(fd, buffer, capacity);
    } while (length == -1 && errno == EINTR);
    if (length == -1)
        fail("read");
    return length;
}

#endif
