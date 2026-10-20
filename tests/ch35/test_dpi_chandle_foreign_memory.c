/* C side of test_dpi_chandle_foreign_memory (IEEE 1800-2023 35.5.1.4). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void *c_alloc(int n)
{
    int *p = (int *)malloc(sizeof(int) * (size_t)n);
    for (int i = 0; p != NULL && i < n; i++)
        p[i] = i * i;
    return p;
}

int c_read(void *h, int i)
{
    return h != NULL ? ((int *)h)[i] : -1;
}

void c_release(void *h)
{
    free(h);
}

#ifdef __cplusplus
}
#endif
