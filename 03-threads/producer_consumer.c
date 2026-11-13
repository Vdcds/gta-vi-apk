#include "../common/sync.h"

#define BUFFER_SIZE 5
#define ITEMS 10

static int buffer[BUFFER_SIZE], in, out;
static sem_t *empty, *full;
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

static void *producer(void *argument)
{
    (void)argument;
    for (int i = 1; i <= ITEMS; ++i) {
        take(empty);
        thread_check(pthread_mutex_lock(&mutex), "pthread_mutex_lock");
        buffer[in] = i * 10;
        printf("Producer produced: %d at position %d\n", buffer[in], in);
        in = (in + 1) % BUFFER_SIZE;
        thread_check(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock");
        release(full);
    }
    return NULL;
}

static void *consumer(void *argument)
{
    (void)argument;
    for (int i = 0; i < ITEMS; ++i) {
        take(full);
        thread_check(pthread_mutex_lock(&mutex), "pthread_mutex_lock");
        printf("Consumer consumed: %d from position %d\n", buffer[out], out);
        out = (out + 1) % BUFFER_SIZE;
        thread_check(pthread_mutex_unlock(&mutex), "pthread_mutex_unlock");
        release(empty);
    }
    return NULL;
}

int main(void)
{
    pthread_t prod, cons;
    empty = new_semaphore(BUFFER_SIZE);
    full = new_semaphore(0);
    thread_check(pthread_create(&prod, NULL, producer, NULL), "pthread_create");
    thread_check(pthread_create(&cons, NULL, consumer, NULL), "pthread_create");
    thread_check(pthread_join(prod, NULL), "pthread_join");
    thread_check(pthread_join(cons, NULL), "pthread_join");
    sem_close(empty);
    sem_close(full);
    thread_check(pthread_mutex_destroy(&mutex), "pthread_mutex_destroy");
    return 0;
}
