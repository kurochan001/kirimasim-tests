/* C side of test_svdpi_h_partsel_get_put_bit_logic_width_32 (IEEE 1800-2023 I.3). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

/* The w low bits; written out because SV_MASK(32) would shift by 32. */
static unsigned low_bits(unsigned v, int w)
{
    return w == 32 ? v : (v & ((1u << w) - 1u));
}

void dpi_get_parts(const svBitVecVal *b, const svLogicVecVal *l)
{
    static const int bit_parts[4][2] = {{0, 8}, {28, 8}, {32, 32}, {20, 32}};
    static const int logic_parts[2][2] = {{36, 8}, {16, 32}};
    int k;

    for (k = 0; k < 4; k++) {
        svBitVecVal d = 0;
        svGetPartselBit(&d, b, bit_parts[k][0], bit_parts[k][1]);
        printf("bit part at %d width %d: %08x\n", bit_parts[k][0], bit_parts[k][1],
               low_bits((unsigned)d, bit_parts[k][1]));
    }
    for (k = 0; k < 2; k++) {
        svLogicVecVal e;
        e.aval = 0;
        e.bval = 0;
        svGetPartselLogic(&e, l, logic_parts[k][0], logic_parts[k][1]);
        printf("logic part at %d width %d: aval %08x bval %08x\n", logic_parts[k][0],
               logic_parts[k][1], low_bits((unsigned)e.aval, logic_parts[k][1]),
               low_bits((unsigned)e.bval, logic_parts[k][1]));
    }
    fflush(stdout);
}

void dpi_put_parts(svBitVecVal *b, svLogicVecVal *l)
{
    svLogicVecVal s;

    svPutPartselBit(b, 0xa5a5a5a5u, 20, 32);
    svPutPartselBit(b, 0x3cu, 60, 4);
    s.aval = 0x00000006u;
    s.bval = 0x00000000u;
    svPutPartselLogic(l, s, 44, 4);
    s.aval = 0x12345678u;
    s.bval = 0x00000000u;
    svPutPartselLogic(l, s, 4, 32);
}

#ifdef __cplusplus
}
#endif
