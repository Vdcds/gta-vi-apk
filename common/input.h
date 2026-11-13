#ifndef LAB_INPUT_H
#define LAB_INPUT_H

#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>

/* Read a bounded integer without variable-length arrays or integer overflow. */
static inline int read_int(int minimum, int maximum)
{
    char token[64], *end;
    long value;
    if (scanf("%63s", token) != 1) {
        fprintf(stderr, "Expected an integer (%d to %d).\n", minimum, maximum);
        exit(EXIT_FAILURE);
    }
    errno = 0;
    value = strtol(token, &end, 10);
    if (errno || *end || value < minimum || value > maximum) {
        fprintf(stderr, "Invalid integer: %s (allowed %d to %d).\n",
                token, minimum, maximum);
        exit(EXIT_FAILURE);
    }
    return (int)value;
}

#endif
