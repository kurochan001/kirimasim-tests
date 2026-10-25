/* C side of test_dpi_enum_base_type_representation (IEEE 1800-2023 H.7.3). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_enums(char eb, short es, int ei, long long el, svBit ebt, svLogic elg,
             const svLogicVecVal *eig, const svLogicVecVal *etm, const svBitVecVal *ebv,
             const svLogicVecVal *elv, const svLogicVecVal *erg, unsigned char ebu,
             const svBitVecVal *etn, int *oi, svLogicVecVal *oig)
{
    printf("by value: byte %d shortint %d int %d longint %lld bit %d logic %d byte unsigned %u\n",
           (int)(signed char)eb, es, ei, el, (int)ebt, (int)elg, (unsigned)ebu);
    printf("integer: aval %08x bval %08x\n", (unsigned)eig->aval, (unsigned)eig->bval);
    printf("time: aval %08x %08x bval %08x %08x\n", (unsigned)etm[1].aval, (unsigned)etm[0].aval,
           (unsigned)etm[1].bval, (unsigned)etm[0].bval);
    printf("bit [7:0] %02x, logic [5:0] aval %02x bval %02x, reg [3:0] aval %x bval %x\n",
           (unsigned)(ebv[0] & 0xffu), (unsigned)(elv->aval & 0x3fu),
           (unsigned)(elv->bval & 0x3fu), (unsigned)(erg->aval & 0xfu),
           (unsigned)(erg->bval & 0xfu));
    printf("named bit [2:0] base %x\n", (unsigned)(etn[0] & 0x7u));
    *oi = 2;
    oig->aval = 7u;
    oig->bval = 0u;
    fflush(stdout);
}

char c_next(char x) { return (char)(x + 1); }

#ifdef __cplusplus
}
#endif
