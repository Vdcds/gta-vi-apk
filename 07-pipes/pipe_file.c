#include <signal.h>
#include <string.h>
#include <sys/wait.h>
#include "../common/io.h"

int main(int argc, char *argv[])
{
    int request[2], response[2];
    char filename[4096];
    signal(SIGPIPE, SIG_IGN);
    if (argc > 2) {
        fprintf(stderr, "Usage: %s [filename]\n", argv[0]);
        return 1;
    }
    if (argc == 2) {
        if (strlen(argv[1]) >= sizeof(filename)) {
            fprintf(stderr, "Filename too long.\n");
            return 1;
        }
        strcpy(filename, argv[1]);
    } else {
        printf("Enter file name: ");
        fflush(stdout);
        if (!fgets(filename, sizeof(filename), stdin))
            return 1;
        if (!strchr(filename, '\n') && !feof(stdin)) {
            fprintf(stderr, "Filename too long.\n");
            return 1;
        }
        filename[strcspn(filename, "\n")] = '\0';
    }
    if (pipe(request) == -1 || pipe(response) == -1)
        fail("pipe");
    fflush(NULL);
    pid_t child = fork();
    if (child == -1)
        fail("fork");
    if (child == 0) {
        close(request[1]);
        close(response[0]);
        size_t used = 0;
        ssize_t length;
        while (used < sizeof(filename) - 1 &&
               (length = read_some(request[0], filename + used,
                                   sizeof(filename) - 1 - used)) > 0)
            used += (size_t)length;
        filename[used] = '\0';
        close(request[0]);
        FILE *file = fopen(filename, "rb");
        if (!file) {
            char error[4200];
            int size = snprintf(error, sizeof(error), "Error: Cannot open file: %s\n", filename);
            write_all(response[1], error, (size_t)size);
            close(response[1]);
            return 1;
        }
        char buffer[4096];
        size_t size;
        while ((size = fread(buffer, 1, sizeof(buffer), file)) > 0)
            write_all(response[1], buffer, size);
        if (ferror(file))
            fail("read file");
        fclose(file);
        close(response[1]);
        return 0;
    }
    close(request[0]);
    close(response[1]);
    write_all(request[1], filename, strlen(filename));
    close(request[1]);
    puts("Contents of File:");
    fflush(stdout);
    char buffer[4096];
    ssize_t length;
    while ((length = read_some(response[0], buffer, sizeof(buffer))) > 0)
        write_all(STDOUT_FILENO, buffer, (size_t)length);
    close(response[0]);
    int status;
    if (waitpid(child, &status, 0) == -1)
        fail("waitpid");
    return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
}
