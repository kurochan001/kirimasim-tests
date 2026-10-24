/* C side of test_dpi_canonical_partsel_get_keeps_bits (IEEE 1800-2023 H.11.5). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void bit_get(const svBitVecVal *s, svBitVecVal start, int i, int w)
{
    svBitVecVal d = start;
    svGetPartselBit(&d, s, i, w);
    printf("svGetPartselBit i=%d w=%d into %08x: %08x\n", i, w, (unsigned)start, (unsigned)d);
}

static void logic_get(const svLogicVecVal *s, uint32_t a, uint32_t b, int i, int w)
{
    svLogicVecVal d;
    d.aval = a;
    d.bval = b;
    svGetPartselLogic(&d, s, i, w);
    printf("svGetPartselLogic i=%d w=%d into aval %08x bval %08x: aval %08x bval %08x\n", i, w,
           (unsigned)a, (unsigned)b, (unsigned)d.aval, (unsigned)d.bval);
}

void c_run(void)
{
    svBitVecVal b[2];
    svLogicVecVal s[2];

    b[0] = 0x12345678u;
    b[1] = 0x9abcdef0u;
    bit_get(b, 0xffffffffu, 28, 8);
    bit_get(b, 0xfffffff0u, 36, 1);
    bit_get(b, 0x80000000u, 0, 31);
    bit_get(b, 0x80000000u, 33, 31);
    bit_get(b, 0xffffffffu, 0, 32);

    s[0].aval = 0x9abcdef0u;
    s[0].bval = 0x0000f00fu;
    s[1].aval = 0x000000c5u;
    s[1].bval = 0x0000005au;
    logic_get(s, 0xaaaaaa55u, 0x5555aa00u, 28, 8);
    logic_get(s, 0xfffffff0u, 0x0000000eu, 38, 1);
    logic_get(s, 0x00000000u, 0xffffffffu, 20, 16);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
