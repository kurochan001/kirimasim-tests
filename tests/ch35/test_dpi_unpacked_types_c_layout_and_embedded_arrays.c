/* C side of test_dpi_unpacked_types_c_layout_and_embedded_arrays (IEEE 1800-2023 H.7.3). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    char b;
    int i;
    long long l;
    double r;
    short s;
} basic_t;

typedef struct {
    int n;
    svLogicVecVal v[3][SV_PACKED_DATA_NELEMS(8)];
    svBitVecVal w[2][SV_PACKED_DATA_NELEMS(40)];
} arr_t;

void c_basic(const basic_t *x, basic_t *y, const double *ra, const char *ba)
{
    printf("x: b %d i %d l %lld r %.2f s %d\n", (int)(signed char)x->b, x->i, x->l, x->r, x->s);
    printf("ra in C order: %.1f %.1f %.1f, ba in C order: %d %d %d %d\n", ra[0], ra[1], ra[2],
           (int)ba[0], (int)ba[1], (int)ba[2], (int)ba[3]);
    y->b = 9;
    y->i = -5;
    y->l = 1LL << 40;
    y->r = -0.5;
    y->s = 321;
    fflush(stdout);
}

void c_arrays(const arr_t *a, const svLogicVecVal *sv, const svBitVecVal *sw)
{
    int k;

    printf("a.n %d, a.v in C order:", a->n);
    for (k = 0; k < 3; k++)
        printf(" %02x/%02x", (unsigned)(a->v[k][0].aval & 0xffu),
               (unsigned)(a->v[k][0].bval & 0xffu));
    printf(", a.w in C order:");
    for (k = 0; k < 2; k++)
        printf(" %02x%08x", (unsigned)(a->w[k][1] & 0xffu), (unsigned)a->w[k][0]);
    printf("\nsv in C order:");
    for (k = 0; k < 3; k++)
        printf(" %02x", (unsigned)(sv[k].aval & 0xffu));
    printf(", sw in C order:");
    for (k = 0; k < 2; k++)
        printf(" %02x%08x", (unsigned)(sw[2 * k + 1] & 0xffu), (unsigned)sw[2 * k]);
    printf("\n");
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
