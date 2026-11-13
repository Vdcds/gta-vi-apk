#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>
#include "../common/input.h"

static void sort_and_print(int values[], int count, const char *who)
{
    for (int i = 0; i < count - 1; ++i)
        for (int j = 0; j < count - i - 1; ++j)
            if (values[j] > values[j + 1]) {
                int temporary = values[j];
                values[j] = values[j + 1];
                values[j + 1] = temporary;
            }
    printf("Sorted Array by %s:", who);
    for (int i = 0; i < count; ++i)
        printf(" %d", values[i]);
    putchar('\n');
}

int main(void)
{
    int values[1000];
    printf("Enter number of elements (1-1000): ");
    int count = read_int(1, 1000);
    printf("Enter elements:\n");
    for (int i = 0; i < count; ++i)
        values[i] = read_int(INT_MIN, INT_MAX);

    fflush(NULL);
    pid_t child = fork();
    if (child == -1) {
        perror("fork");
        return 1;
    }
    if (child == 0) {
        puts("\nCHILD PROCESS");
        sort_and_print(values, count, "Child");
        printf("Child PID = %ld\nParent PID = %ld\n", (long)getpid(), (long)getppid());
        return 0;
    }
    int status;
    if (waitpid(child, &status, 0) == -1) {
        perror("waitpid");
        return 1;
    }
    if (!WIFEXITED(status) || WEXITSTATUS(status) != 0)
        return 1;
    puts("\nPARENT PROCESS");
    sort_and_print(values, count, "Parent");
    printf("Parent PID = %ld\n", (long)getpid());
    return 0;
}
