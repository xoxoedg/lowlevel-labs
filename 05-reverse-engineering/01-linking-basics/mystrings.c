int my_strlen(char* str) {
    char token;
    int counter = 0;
    while(*(str + counter) != '\0') {
        counter++;
    }
    return counter;
}

char* my_strcpy(char* dest, const char* source) {
    int counter = 0;
    while (*(source+counter) != '\0') {
        *(dest+counter) = *(source+counter);
        counter++;
    }
    *(dest+counter) = '\0';

    return dest;
}