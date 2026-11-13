#include <fcntl.h>
#include <signal.h>
#include <string.h>
#include "../common/io.h"

int main(void)
{
    char message[500], result[1024];
    signal(SIGPIPE, SIG_IGN);
    puts("Enter a sentence (up to 499 characters):");
    if (!fgets(message, sizeof(message), stdin)) {
        fprintf(stderr, "Expected a sentence.\n");
        return 1;
    }
    if (!strchr(message, '\n') && !feof(stdin)) {
        int next = getchar();
        if (next != '\n' && next != EOF) {
            fprintf(stderr, "Sentence is too long (maximum 499 characters).\n");
            return 1;
        }
    }
    message[strcspn(message, "\n")] = '\0';

    int request = open("fifo1", O_WRONLY);
    if (request == -1)
        fail("open fifo1 (start with ./run.sh fifo)");
    write_all(request, message, strlen(message));
    close(request);

    int response = open("fifo2", O_RDONLY);
    if (response == -1)
        fail("open fifo2");
    puts("\nOutput received from Process 2:");
    fflush(stdout);
    ssize_t length;
    while ((length = read_some(response, result, sizeof(result))) > 0)
        write_all(STDOUT_FILENO, result, (size_t)length);
    close(response);
    return 0;
}
