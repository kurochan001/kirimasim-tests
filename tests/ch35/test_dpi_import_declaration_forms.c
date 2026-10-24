/* C side of test_dpi_import_declaration_forms (IEEE 1800-2023 35.5.4). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int counter;

int c_count(void)
{
    return ++counter;
}

void c_reset(int v)
{
    counter = v;
}

int c_split(int v, int *hi, int *lo)
{
    *hi = (int)(((unsigned int)v >> 16) & 0xffffu);
    *lo = (int)((unsigned int)v & 0xffffu);
    return 2;
}

void c_twice(int *v)
{
    *v = *v * 2;
}

/* Imported tasks are int functions in C; 0 means "not disabled" (35.9). */
int c_swap(int *a, int *b)
{
    int t = *a;
    *a = *b;
    *b = t;
    return 0;
}

int c_add_hundred(void)
{
    counter += 100;
    return 0;
}

#ifdef __cplusplus
}
#endif
