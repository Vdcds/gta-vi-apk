#include <stdio.h>
#include "../common/input.h"

#define LIMIT 100

int main(void)
{
    int allocation[LIMIT][LIMIT], need[LIMIT][LIMIT];
    int work[LIMIT], finished[LIMIT] = {0}, sequence[LIMIT];
    printf("Enter number of processes (1-100): ");
    int processes = read_int(1, LIMIT);
    printf("Enter number of resource types (1-100): ");
    int resources = read_int(1, LIMIT);

    puts("Enter Allocation Matrix:");
    for (int i = 0; i < processes; ++i)
        for (int j = 0; j < resources; ++j)
            allocation[i][j] = read_int(0, 1000000);

    puts("Enter Maximum Matrix:");
    for (int i = 0; i < processes; ++i)
        for (int j = 0; j < resources; ++j) {
            int maximum = read_int(allocation[i][j], 1000000);
            need[i][j] = maximum - allocation[i][j];
        }

    puts("Enter Available Resources:");
    for (int j = 0; j < resources; ++j)
        work[j] = read_int(0, 1000000);

    int count = 0;
    while (count < processes) {
        int progress = 0;
        for (int i = 0; i < processes; ++i) {
            if (finished[i])
                continue;
            int j;
            for (j = 0; j < resources; ++j)
                if (need[i][j] > work[j])
                    break;
            if (j != resources)
                continue;
            for (j = 0; j < resources; ++j)
                work[j] += allocation[i][j];
            sequence[count++] = i;
            finished[i] = 1;
            progress = 1;
        }
        if (!progress) {
            puts("System is NOT in Safe State.");
            return 0;
        }
    }
    puts("System is in Safe State.");
    printf("Safe Sequence: ");
    for (int i = 0; i < processes; ++i)
        printf("P%d%s", sequence[i], i + 1 == processes ? "\n" : " -> ");
    return 0;
}
