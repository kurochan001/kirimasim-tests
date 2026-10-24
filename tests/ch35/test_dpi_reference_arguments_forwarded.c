/* C side of test_dpi_reference_arguments_forwarded (IEEE 1800-2023 H.8.4). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern void sv_fill(int *n, svBitVecVal *w, svLogicVecVal *l, int *arr);

static void show(const char *who, const int *n, const svBitVecVal *w, const svLogicVecVal *l,
                 const int *arr)
{
    printf("%s: n %d w %02x%08x l %02x arr %d %d %d\n", who, *n, (unsigned)(w[1] & 0xffu),
           (unsigned)w[0], (unsigned)(l->aval & 0xffu), arr[0], arr[1], arr[2]);
    fflush(stdout);
}

void c_own(void)
{
    int n = 0;
    svBitVecVal w[2] = {0, 0};
    svLogicVecVal l;
    int arr[3] = {4, 5, 6};

    l.aval = 0x20u;
    l.bval = 0;
    sv_fill(&n, w, &l, arr);
    show("c_own", &n, w, &l, arr);
}

void c_forward(int *n, svBitVecVal *w, svLogicVecVal *l, int *arr)
{
    sv_fill(n, w, l, arr);
    show("c_forward", n, w, l, arr);
    *n += 1;
    w[0] ^= 0xffu;
    l->aval = (l->aval + 1) & 0xffu;
    arr[2] += 5;
}

#ifdef __cplusplus
}
#endif
