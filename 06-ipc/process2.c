#include <ctype.h>
#include <fcntl.h>
#include <signal.h>
#include "../common/io.h"

int main(void)
{
    char buffer[1024], result[256];
    size_t characters = 0, words = 0, newlines = 0;
    int in_word = 0, last = '\n';
    signal(SIGPIPE, SIG_IGN);
    int request = open("fifo1", O_RDONLY);
    if (request == -1)
        fail("open fifo1 (start with ./run.sh fifo)");
    ssize_t length;
    while ((length = read_some(request, buffer, sizeof(buffer))) > 0) {
        for (ssize_t i = 0; i < length; ++i) {
            unsigned char character = (unsigned char)buffer[i];
            ++characters;
            if (character == '\n')
                ++newlines;
            if (isspace(character)) {
                in_word = 0;
            } else if (!in_word) {
                ++words;
                in_word = 1;
            }
            last = character;
        }
    }
    close(request);
    size_t lines = newlines + (characters > 0 && last != '\n');
    int size = snprintf(result, sizeof(result),
                        "Number of Characters = %zu\nNumber of Words = %zu\n"
                        "Number of Lines = %zu\n", characters, words, lines);
    FILE *file = fopen("result.txt", "w");
    if (!file)
        fail("fopen result.txt");
    if (fputs(result, file) == EOF)
        fail("write result.txt");
    if (fclose(file) == EOF)
        fail("close result.txt");

    int response = open("fifo2", O_WRONLY);
    if (response == -1)
        fail("open fifo2");
    write_all(response, result, (size_t)size);
    close(response);
    return 0;
}
