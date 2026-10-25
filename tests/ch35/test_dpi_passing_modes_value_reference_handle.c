/* C side of test_dpi_passing_modes_value_reference_handle (IEEE 1800-2023 H.8). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int counter = 1234;

void *c_handle(void) { return &counter; }

int c_in(char b, short s, int i, long long l, double r, float sr, void *c, const char *str,
         svBit bt, svLogic lg, const svBitVecVal *pb, const svLogicVecVal *pl,
         const svLogicVecVal *ig, const svLogicVecVal *t, const svOpenArrayHandle oa)
{
    printf("by value: byte %d shortint %d int %d longint %lld real %.2f shortreal %.2f\n",
           (int)(signed char)b, s, i, l, r, (double)sr);
    printf("by value: chandle to %d, string %s, bit %d, logic %d\n", *(int *)c, str, (int)bt,
           (int)lg);
    printf("by reference: bit [7:0] %02x, logic [3:0] aval %x bval %x\n",
           (unsigned)(pb[0] & 0xffu), (unsigned)(pl->aval & 0xfu), (unsigned)(pl->bval & 0xfu));
    printf("by reference: integer aval %08x bval %08x, time %08x %08x\n", (unsigned)ig->aval,
           (unsigned)ig->bval, (unsigned)t[1].aval, (unsigned)t[0].aval);
    printf("by handle: oa[2] %d oa[0] %d\n", *(const int *)svGetArrElemPtr1(oa, 2),
           *(const int *)svGetArrElemPtr1(oa, 0));
    fflush(stdout);
    return 15;
}

void c_out(char *ob, double *orl, const char **os, svBit *obt, svLogicVecVal *opl, int *ioi)
{
    *ob = -100;
    *orl = 6.25;
    *os = "out";
    *obt = sv_1;
    opl->aval = 0x5au;
    opl->bval = 0;
    *ioi += 1;
}

char r_byte(void) { return -7; }
short r_shortint(void) { return -32000; }
int r_int(void) { return 123456789; }
long long r_longint(void) { return -9000000000LL; }
double r_real(void) { return 1.125; }
float r_shortreal(void) { return 0.5f; }
const char *r_string(void) { return "res"; }
svBit r_bit(void) { return sv_1; }
svLogic r_logic(void) { return sv_0; }

#ifdef __cplusplus
}
#endif
