/* C side of test_35_extra_H_8_10_1_string_arrays (IEEE 1800-2023 H.8.10.1). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void s_in(const char **a)
{
    printf("in %s %s %s\n", a[0], a[1], a[2]);
}

void s_out(const char **a)
{
    a[0] = "one";
    a[1] = "two";
    a[2] = "three";
}

void s_inout(const char **a)
{
    printf("inout before %s\n", a[0]);
    a[0] = "delta";
}

#ifdef __cplusplus
}
#endif
