#include <stdio.h>
void _addone(void *memloc, size_t nbytes) {
  for (size_t i = 0; i < nbytes; ++i)
    memloc[i]++;
}
