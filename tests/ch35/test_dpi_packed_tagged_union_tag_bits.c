/* C side of test_dpi_packed_tagged_union_tag_bits (IEEE 1800-2023 H.7.4). */
#include <stdio.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_two(const char *name, const svBitVecVal *u)
{
    unsigned tag = (unsigned)((u[0] >> 12) & 0x3u);
    unsigned member = (unsigned)(u[0] & (strcmp(name, "narrow") == 0 ? 0xffu : 0xfffu));

    printf("tagged %s: tag bits 13:12 = %u, member bits = %x\n", name, tag, member);
    fflush(stdout);
}

void c_four(const svLogicVecVal *v)
{
    printf("tagged b: aval %02x, bval %02x\n", (unsigned)(v[0].aval & 0x1fu),
           (unsigned)(v[0].bval & 0x1fu));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
