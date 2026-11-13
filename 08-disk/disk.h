#ifndef LAB_DISK_H
#define LAB_DISK_H

#include "../common/input.h"

#define MAX_REQUESTS 1000
#define LAST_TRACK 199

static inline int read_queue(int requests[], int *head)
{
    printf("Enter number of requests (1-1000): ");
    int count = read_int(1, MAX_REQUESTS);
    puts("Enter request queue (tracks 0-199):");
    for (int i = 0; i < count; ++i)
        requests[i] = read_int(0, LAST_TRACK);
    printf("Enter initial head position (0-199): ");
    *head = read_int(0, LAST_TRACK);
    return count;
}

static inline void sort_queue(int requests[], int count)
{
    for (int i = 0; i < count - 1; ++i)
        for (int j = 0; j < count - i - 1; ++j)
            if (requests[j] > requests[j + 1]) {
                int temporary = requests[j];
                requests[j] = requests[j + 1];
                requests[j + 1] = temporary;
            }
}

static inline void seek(int *head, int next, int *total)
{
    *total += abs(*head - next);
    *head = next;
    printf(" -> %d", next);
}

static inline void print_totals(int total, int count)
{
    printf("\nTotal Seek Operations = %d\n", total);
    printf("Average Seek Length = %.2f\n", (double)total / count);
}

#endif
