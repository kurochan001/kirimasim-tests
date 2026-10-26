#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

static void print_value(const svOpenArrayHandle h)
{
    const svLogic *e;
    unsigned value = 0;
    int i, n = svSizeOfArray(h);

    for (i = 0; i < n; i++) {
        e = (const svLogic *)svGetArrElemPtr1(h, i);
        if (e != NULL && (*e & 1)) value |= 1u << i;
    }
    printf("size %d value %02x\n", n, value);
    fflush(stdout);
}

void c_packed(const svOpenArrayHandle v)
{
    print_value(v);
}

#ifdef __cplusplus
}
#endif
