#include <stdio.h>
#include <stdlib.h>

void secret() {
    printf("You shouldn't be here!\n");
    exit(0);
}

void vulnerable(char *input) {
    char buffer[64];
    strcpy(buffer, input);
    printf("You entered: %s\n", buffer);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Usage: %s <input>\n", argv[0]);
        return 1;
    }
    vulnerable(argv[1]);
    return 0;
}