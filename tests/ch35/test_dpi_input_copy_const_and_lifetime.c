/* C side of test_dpi_input_copy_const_and_lifetime (IEEE 1800-2023 H.6, H.6.2, H.8.4). */
#include <stdio.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static char kept_s[32];
static long long kept_n;
static svLogicVecVal kept_v[2];
static int calls = 0;

void c_keep(const char *s, long long n, const svLogicVecVal *v, int *o)
{
    if (calls == 0) {
        strncpy(kept_s, s, sizeof kept_s - 1);
        kept_s[sizeof kept_s - 1] = '\0';
        kept_n = n;
        kept_v[0] = v[0];
        kept_v[1] = v[1];
        printf("first %s %lld %08x%08x\n", s, n,
               (unsigned)v[1].aval, (unsigned)v[0].aval);
    } else {
        printf("second %s %lld %08x%08x\n", s, n,
               (unsigned)v[1].aval, (unsigned)v[0].aval);
        printf("kept %s %lld %08x%08x\n", kept_s, kept_n,
               (unsigned)kept_v[1].aval, (unsigned)kept_v[0].aval);
    }
    calls++;
    *o = calls;
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
