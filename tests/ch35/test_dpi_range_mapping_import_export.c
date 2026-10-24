/* C side of test_dpi_range_mapping_import_export (IEEE 1800-2023 H.7.6). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void sv_export(const svBitVecVal *p, const svBitVecVal *q, const int *u, int *o);

void c_import(const svBitVecVal *p, const svBitVecVal *q, const int *u, int *o)
{
    int k;

    printf("c_import: p = %02x, q = %02x, u in C order: %d %d %d %d\n",
           (unsigned)(p[0] & 0xffu), (unsigned)(q[0] & 0xffu), u[0], u[1], u[2], u[3]);
    for (k = 0; k < 4; k++)
        o[k] = 100 + k;
    fflush(stdout);
}

void c_call_export(void)
{
    svBitVecVal p = 0x83u, q = 0xa5u;
    int u[4] = {10, 20, 30, 40};
    int o[4] = {0, 0, 0, 0};

    sv_export(&p, &q, u, o);
    printf("c_call_export: o in C order: %d %d %d %d\n", o[0], o[1], o[2], o[3]);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
