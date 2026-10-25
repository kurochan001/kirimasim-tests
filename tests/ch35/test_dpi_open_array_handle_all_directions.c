/* C side of test_dpi_open_array_handle_all_directions (IEEE 1800-2023 H.12, H.8.6). */
#include <stdio.h>
#include "svdpi.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif

void c_dirs(const svOpenArrayHandle i, const svOpenArrayHandle o, const svOpenArrayHandle io,
            const svOpenArrayHandle ol, const svOpenArrayHandle ib, int n, int *on,
            svBitVecVal *ion)
{
    svOpenArrayHandle h = i;
    int k, sum = 0, whole_ok = 1;
    const int *whole = (const int *)svGetArrayPtr(i);
    svLogicVecVal v;

    printf("svOpenArrayHandle is void *: %d\n", SAME_TYPE(h, void *));
    for (k = 1; k <= 3; k++) {
        sum += *(const int *)svGetArrElemPtr1(i, k);
        if (whole != NULL && whole[k - 1] != *(const int *)svGetArrElemPtr1(i, k))
            whole_ok = 0;
    }
    printf("input i: sum %d, svGetArrayPtr NULL or the same elements %d\n", sum, whole_ok);
    printf("output o: %d elements from %d to %d\n", svSize(o, 1), svLeft(o, 1), svRight(o, 1));
    for (k = svLow(o, 1); k <= svHigh(o, 1); k++)
        *(int *)svGetArrElemPtr1(o, k) = 7 * k;
    for (k = 0; k <= 1; k++)
        *(int *)svGetArrElemPtr1(io, k) += 1000;
    v.bval = 0;
    v.aval = 0xa5u;
    svPutLogicArrElem1VecVal(ol, &v, 2);
    v.aval = 0x3cu;
    svPutLogicArrElem1VecVal(ol, &v, 3);
    for (k = 0; k <= 2; k++)
        svPutBitArrElem1(ib, svGetBitArrElem1(ib, k) == sv_1 ? sv_0 : sv_1, k);
    printf("n by value %d\n", n);
    *on = n + 1;
    *ion = ~*ion & 0xffu;
    fflush(stdout);
}

void c_fill(const svOpenArrayHandle f)
{
    int k;

    printf("c_fill: room for %d elements\n", svSize(f, 1));
    for (k = svLow(f, 1); k <= svHigh(f, 1); k++)
        *(int *)svGetArrElemPtr1(f, k) = 100 + k;
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
