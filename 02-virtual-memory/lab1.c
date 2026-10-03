#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>

#define SIZE (1024UL * 1024 * 1024)  // 1 GB

int main(void) {
    printf("PID: %d\n", getpid());

    char *p = mmap(NULL, SIZE, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS,-1, 0);
    if (p == MAP_FAILED) {
        perror("mmap failed: ");
        return 1;
    }

    puts("Haltepunkt 1: gemappt, nichts angefasst");
    getchar();
    int count_loops = SIZE/4096;
    size_t page_offset = 0;
    for(int i=0; i<count_loops;i++) {
       p[page_offset] = 0;
       page_offset += 4096;
    }

    puts("Haltepunkt 2: jede Seite angefasst");
    getchar();
    return 0;
}
