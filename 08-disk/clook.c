#include "disk.h"

int main(void)
{
    int requests[MAX_REQUESTS], head, total = 0;
    int count = read_queue(requests, &head);
    sort_queue(requests, count);
    int split = 0;
    while (split < count && requests[split] < head)
        ++split;
    printf("\nSeek Sequence: %d", head);
    for (int i = split; i < count; ++i)
        seek(&head, requests[i], &total);
    /* The wrap to the lowest pending request counts toward head movement. */
    for (int i = 0; i < split; ++i)
        seek(&head, requests[i], &total);
    print_totals(total, count);
    return 0;
}
