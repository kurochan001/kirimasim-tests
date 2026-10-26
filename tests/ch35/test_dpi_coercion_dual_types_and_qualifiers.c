/* C side of test_dpi_coercion_dual_types_and_qualifiers (IEEE 1800-2023 H.6, H.6.1, H.7.2). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int c_types(char b, short s, int i, long long l, double r,
            const svLogicVecVal *lv, const svBitVecVal *bv, const char *str)
{
    printf("types %d %d %d %lld %.2f %02x %x %s\n",
           (int)b, (int)s, i, l, r,
           (unsigned)(lv[0].aval & 0xFFu), (unsigned)(bv[0] & 0xFu), str);
    return 1;
}

int c_rand(const svBitVecVal *v, const svBitVecVal *c)
{
    return (int)((v[0] & 0xFFu) == 0xA5u && (c[0] & 0xFu) == 0x3u);
}

#ifdef __cplusplus
}
#endif
