#ifndef LAB_SYNC_H
#define LAB_SYNC_H

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <semaphore.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static inline void thread_check(int result, const char *operation)
{
    if (result) {
        fprintf(stderr, "%s: %s\n", operation, strerror(result));
        exit(EXIT_FAILURE);
    }
}

/* Named semaphores work on both Linux and macOS. Unlink immediately so the
   name cannot outlive this demo; the open handle stays valid until closed. */
static inline sem_t *new_semaphore(unsigned value)
{
    static unsigned serial;
    char name[32];
    sem_t *semaphore;
    do {
        snprintf(name, sizeof(name), "/oslab_%ld_%u", (long)getpid(), serial++);
        semaphore = sem_open(name, O_CREAT | O_EXCL, 0600, value);
    } while (semaphore == SEM_FAILED && errno == EEXIST);
    if (semaphore == SEM_FAILED) {
        perror("sem_open");
        exit(EXIT_FAILURE);
    }
    if (sem_unlink(name) == -1) {
        perror("sem_unlink");
        exit(EXIT_FAILURE);
    }
    return semaphore;
}

static inline void take(sem_t *semaphore)
{
    int result;
    do {
        result = sem_wait(semaphore);
    } while (result == -1 && errno == EINTR);
    if (result == -1) {
        perror("sem_wait");
        exit(EXIT_FAILURE);
    }
}

static inline void release(sem_t *semaphore)
{
    if (sem_post(semaphore) == -1) {
        perror("sem_post");
        exit(EXIT_FAILURE);
    }
}

#endif
