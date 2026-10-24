/* C side of test_dpi_unsigned_atoms_and_packed_by_reference (IEEE 1800-2023 H.7.4, H.8.7). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_in(unsigned char bu, const svBitVecVal *bv, unsigned short su, const svBitVecVal *sv,
          const svLogicVecVal *lv, const int *arr, const svBitVecVal *ps, const svBitVecVal *pu)
{
    printf("c_in: byte unsigned %u, bit [7:0] %u\n", (unsigned)bu, (unsigned)(bv[0] & 0xffu));
    printf("c_in: shortint unsigned %u, bit [15:0] %u\n", (unsigned)su,
           (unsigned)(sv[0] & 0xffffu));
    printf("c_in: logic [7:0] aval %02x bval %02x\n", (unsigned)(lv[0].aval & 0xffu),
           (unsigned)(lv[0].bval & 0xffu));
    printf("c_in: int [3] %d %d %d\n", arr[0], arr[1], arr[2]);
    printf("c_in: packed struct %03x, packed union %03x\n", (unsigned)(ps[0] & 0xfffu),
           (unsigned)(pu[0] & 0xfffu));
    fflush(stdout);
}

void c_out(unsigned char *bu, svBitVecVal *bv, unsigned short *su, svBitVecVal *sv,
           svBitVecVal *ps)
{
    *bu = 0xf0u;
    bv[0] = 0x0fu;
    *su = 0xbeefu;
    sv[0] = 0xcafeu;
    ps[0] = 0x7e1u;
}

#ifdef __cplusplus
}
#endif
