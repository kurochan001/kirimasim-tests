#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

/* The formal logic [] has no unpacked dimension: dimension 0 is its packed
 * part with the normalized range (H.7.6, H.12.2). svGetArrayPtr gives the
 * whole array, here one packed value in canonical form (H.7.7), or NULL when
 * the array is not in the C layout (H.12.4); NULL is accepted. */
static void print_value(const svOpenArrayHandle h, int want)
{
    const svLogicVecVal *p = (const svLogicVecVal *)svGetArrayPtr(h);
    int ok = p == NULL || ((p[0].aval & 0xffu) == (unsigned)want
                           && (p[0].bval & 0xffu) == 0);

    printf("size %d left %d right %d value %s\n", svSize(h, 0), svLeft(h, 0),
           svRight(h, 0), ok ? "ok" : "differs");
    fflush(stdout);
}

void c_packed(const svOpenArrayHandle v, int want)
{
    print_value(v, want);
}

#ifdef __cplusplus
}
#endif
