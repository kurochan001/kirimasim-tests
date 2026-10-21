/* C side of test_dpi_input_inout_semantics (IEEE 1800-2023 35.5.1.2). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_countdown(int n)
{
    int steps = 0;
    while (n > 0) {
        n--;
        steps++;
    }
    return steps;
}

int c_length(const char *s)
{
    int len = 0;
    while (*s != '\0') {
        s++;
        len++;
    }
    return len;
}

void c_accumulate(double *total, double add)
{
    *total += add;
}

void c_rotate(int *a)
{
    int first = a[0];
    a[0] = a[1];
    a[1] = a[2];
    a[2] = a[3];
    a[3] = first;
}

void c_add_wide(svBitVecVal *v, int add)
{
    unsigned long long full = ((unsigned long long)(v[1] & 0xffu) << 32) | v[0];
    full += (unsigned long long)add;
    v[0] = (svBitVecVal)(full & 0xffffffffu);
    v[1] = (svBitVecVal)((full >> 32) & 0xffu);
}

#ifdef __cplusplus
}
#endif
