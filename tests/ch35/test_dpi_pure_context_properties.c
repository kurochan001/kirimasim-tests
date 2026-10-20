/* C side of test_dpi_pure_context_properties (IEEE 1800-2023 35.5.1.3). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int ticks;

extern int sv_add(int v);

int c_square(int v)
{
    return v * v;
}

int c_feed(int v)
{
    sv_add(v);
    return sv_add(v);
}

int c_tick(void)
{
    return ++ticks;
}

#ifdef __cplusplus
}
#endif
