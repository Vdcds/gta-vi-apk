#include "disk.h"

int main(void)
{
    int requests[MAX_REQUESTS], head, total = 0;
    int count = read_queue(requests, &head);
    sort_queue(requests, count);
    /* Keep this boundary fixed: comparing against a moving head would cause
       already serviced requests to appear again on the return sweep. */
    int split = 0;
    while (split < count && requests[split] < head)
        ++split;
    printf("\nSeek Sequence: %d", head);
    for (int i = split; i < count; ++i)
        seek(&head, requests[i], &total);
    if (head != LAST_TRACK)
        seek(&head, LAST_TRACK, &total);
    for (int i = split - 1; i >= 0; --i)
        seek(&head, requests[i], &total);
    print_totals(total, count);
    return 0;
}
