#include "disk.h"

int main(void)
{
    int requests[MAX_REQUESTS], visited[MAX_REQUESTS] = {0}, head, total = 0;
    int count = read_queue(requests, &head);
    printf("\nSeek Sequence: %d", head);
    for (int served = 0; served < count; ++served) {
        int nearest = -1, distance = INT_MAX;
        for (int i = 0; i < count; ++i) {
            int candidate = abs(head - requests[i]);
            if (!visited[i] && candidate < distance) {
                distance = candidate;
                nearest = i;
            }
        }
        visited[nearest] = 1;
        seek(&head, requests[nearest], &total);
    }
    print_totals(total, count);
    return 0;
}
