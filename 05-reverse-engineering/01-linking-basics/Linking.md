# Linking Basics

## File types:

### .a: Static Archive (static linking)

- static archive (can hold multiple `.o` files)
- used for static linking, code gets copied into the final executable at link time
- symbol index (built via `ar -s`) lets the linker find symbols without scanning every `.o`

```bash
# Create mylib.o
$ gcc -c mylib.c

# lib$LIBRARYNAME.{a,so} are canonical names for libraries
$ ar -rcs libmylib.a mylib.o
```

### .o - Object Files

- compiled, but not yet linked (output of `gcc -c`)
- contains machine code + a symbol table + relocations (placeholders for addresses not yet known)
- external symbols show up as `*UND*` (undefined) until linking resolves them
- final addresses aren't set yet, they get filled in once linked into a `.a`, `.so`, or executable (elf/pe)


### .so: Shared Object (dynamic linking)

- ELF equivalent of Windows' `.dll`
- code stays **external**, not copied into the executable, only referenced
- loaded into memory at runtime, shared across multiple programs that use it
- requires `-fPIC` when compiling the `.o` files that go into it, since code must work at *any* load address (the `.so` can be mapped differently depending on the loading program / ASLR)
- built with `gcc mylib.o -shared -o libmylib.so`
- runtime resolution happens via **GOT + PLT** (lazy binding), see [[#GOT--PLT]]



## Custom Practice Exercise: Building Your Own .so

Goal: build custom string functions as a shared library and dynamically link them against a main program.

### Files

- `mystrings.h`: header with function **declarations** (no implementation)
- `mystrings.c`: the actual **definitions** (function bodies)
- `main.c`: uses the functions via the header

#### mystrings.h

```c
#ifndef MYSTRINGS_H
#define MYSTRINGS_H

char *my_strcpy(char *dest, const char *src);
int my_strlen(char *str);

#endif
```

#### mystrings.c

```c
#include "mystrings.h"

int my_strlen(char* str) {
    int counter = 0;
    while (*(str + counter) != '\0') {
        counter++;
    }
    return counter;
}

char* my_strcpy(char* dest, const char* src) {
    int counter = 0;
    while (*(src + counter) != '\0') {
        *(dest + counter) = *(src + counter);
        counter++;
    }
    *(dest + counter) = '\0';
    return dest;
}
```

#### main.c

```c
#include "mystrings.h"
#include <stdio.h>

int main() {
    char* test = "Hello\n";
    printf("The length of the string is: %d\n", my_strlen(test));
    return 0;
}
```


#### Building and Linking

1) Compile the libary source to an object file:

```bash
gcc -c mystrings.c -o mystrings.o -fPIC
```

2) Create a shared object from it:

```bash
gcc mystrings.o -shared -o libmystrings.so
```

3) Build main and link it against the shared libary libmystrings.so:

```bash
gcc -o main main.c -L. -lmystrings

# -L. tells the linker to look at the current directory for the shared libary
```

4) Add the current directory to the path were the loader ld.so searches for the shared libary: 

```
export LD_LIBRARY_PATH=. 
```

5) Run the binary:

`./main`



## Tools-Cheatsheet
- objdump -x / -d Flags
- ar, gcc-Flags (-fPIC, -static, -nostdlib, ...)
- ldd