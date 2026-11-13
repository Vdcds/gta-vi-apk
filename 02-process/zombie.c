#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void)
{
    setbuf(stdout, NULL);
    pid_t child = fork();
    if (child == -1) {
        perror("fork");
        return 1;
    }
    if (child == 0) {
        puts("Child exits now; it stays a zombie until the parent calls waitpid.");
        _exit(0);
    }
    printf("Parent PID = %ld, child PID = %ld\n", (long)getpid(), (long)child);
    printf("For the next 5 seconds, inspect it in another terminal:\n");
    printf("ps -o pid,ppid,stat,command -p %ld\n", (long)child);
    sleep(5);
    if (waitpid(child, NULL, 0) == -1) {
        perror("waitpid");
        return 1;
    }
    puts("Parent reaped child. Zombie removed.");
    return 0;
}
