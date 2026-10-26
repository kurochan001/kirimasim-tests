/* C side of test_dpi_call_directions_and_context_chain (IEEE 1800-2023 H.2, H.6.5, H.9). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_twice(int x);

int c_add(int a, int b)
{
    return a + b;
}

void c_set(int *o)
{
    *o = 9;
}

static const char *scope_name(void)
{
    svScope s = svGetScope();
    return s != NULL ? svGetNameFromScope(s) : "NULL";
}

int c_chain(int v)
{
    printf("scope %s\n", scope_name());
    return sv_twice(v) + 1;
}

#ifdef __cplusplus
}
#endif
