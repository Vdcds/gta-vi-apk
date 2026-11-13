#include "../common/sync.h"

#define PHILOSOPHERS 5
#define MEALS 3

static sem_t *forks[PHILOSOPHERS], *room;

static void *philosopher(void *argument)
{
    int id = *(int *)argument;
    for (int meal = 1; meal <= MEALS; ++meal) {
        printf("Philosopher %d is Thinking\n", id);
        /* At most N-1 philosophers can try to acquire forks at once. */
        take(room);
        take(forks[id]);
        printf("Philosopher %d picked LEFT fork %d\n", id, id);
        take(forks[(id + 1) % PHILOSOPHERS]);
        printf("Philosopher %d picked RIGHT fork %d\n", id, (id + 1) % PHILOSOPHERS);
        printf("Philosopher %d is Eating (meal %d)\n", id, meal);
        release(forks[(id + 1) % PHILOSOPHERS]);
        release(forks[id]);
        printf("Philosopher %d released forks\n", id);
        release(room);
    }
    return NULL;
}

int main(void)
{
    pthread_t threads[PHILOSOPHERS];
    int ids[PHILOSOPHERS];
    room = new_semaphore(PHILOSOPHERS - 1);
    for (int i = 0; i < PHILOSOPHERS; ++i)
        forks[i] = new_semaphore(1);
    for (int i = 0; i < PHILOSOPHERS; ++i) {
        ids[i] = i;
        thread_check(pthread_create(&threads[i], NULL, philosopher, &ids[i]), "pthread_create");
    }
    for (int i = 0; i < PHILOSOPHERS; ++i) {
        thread_check(pthread_join(threads[i], NULL), "pthread_join");
    }
    for (int i = 0; i < PHILOSOPHERS; ++i)
        sem_close(forks[i]);
    sem_close(room);
    puts("All philosophers finished 3 meals without deadlock.");
    return 0;
}
