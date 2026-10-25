/* C side of test_svdpi_h_packed_bit_and_part_select (IEEE 1800-2023 35.3.2, I.3). */
#include "svdpi.h"
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void dpi_bit_select(const svLogicVecVal *a, const svBitVecVal *b,
                    svLogicVecVal *lput, svBitVecVal *bput)
{
    int i;

    printf("logic vector bits from the LSB:");
    for (i = 0; i < 8; i++)
        printf(" %d", (int)svGetBitselLogic(a, i));
    printf("\nbit vector bits from the LSB:");
    for (i = 0; i < 8; i++)
        printf(" %d", (int)svGetBitselBit(b, i));
    printf("\n");

    svPutBitselLogic(lput, 7, sv_1);
    svPutBitselLogic(lput, 0, sv_1);
    svPutBitselLogic(lput, 3, sv_0);
    svPutBitselBit(bput, 4, 1);
    svPutBitselBit(bput, 3, 1);
    svPutBitselBit(bput, 0, 0);
    fflush(stdout);
}

void dpi_part_select(const svLogicVecVal *c, const svBitVecVal *w, svBitVecVal *d)
{
    svBitVecVal piece;
    svLogicVecVal lpiece;

    svGetPartselBit(&piece, w, 28, 8);
    printf("part of the 64-bit value at 28 width 8: %02x\n", (unsigned)piece);
    svGetPartselBit(&piece, w, 0, 8);
    printf("part at 0 width 8: %02x\n", (unsigned)piece);
    svGetPartselLogic(&lpiece, c, 2, 4);
    printf("part of the logic vector at 2 width 4: %x\n",
           (unsigned)(lpiece.aval & SV_MASK(4)));

    svPutPartselBit(d, 0xabcd, 28, 16);
    fflush(stdout);
}

int dpi_macros(void)
{
    return SV_MASK(1) == 0x1 && SV_MASK(8) == 0xff && SV_MASK(31) == 0x7fffffff &&
           SV_GET_UNSIGNED_BITS(0x89abcdef, 8) == 0xef &&
           SV_GET_UNSIGNED_BITS(0x89abcdef, 32) == 0x89abcdef &&
           SV_GET_UNSIGNED_BITS(0x89abcdef, 31) == 0x09abcdef;
}

#ifdef __cplusplus
}
#endif
