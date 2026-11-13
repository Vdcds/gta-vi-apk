#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    /* Capture before fork, so the child can always report the original parent. */
    pid_t original_parent = getpid();
    setbuf(stdout, NULL);
    pid_t child = fork();
    if (child == -1) {
        perror("fork");
        return 1;
    }
    if (child > 0) {
        printf("Parent PID = %ld exits; child PID = %ld\n",
               (long)original_parent, (long)child);
        return 0;
    }
    sleep(2);
    printf("Child PID = %ld\nOriginal parent PID = %ld\nNew parent PID = %ld\n",
           (long)getpid(), (long)original_parent, (long)getppid());
    return 0;
}
