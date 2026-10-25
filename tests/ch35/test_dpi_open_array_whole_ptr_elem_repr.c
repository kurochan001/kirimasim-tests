/* C side of test_dpi_open_array_whole_ptr_elem_repr (IEEE 1800-2023 H.12.4). */
#include <stdio.h>
#include <string.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The address of the element at C position pos (lowest index first in each
   dimension) of an open array with dims (1 or 2) unpacked dimensions. */
static void *element(const svOpenArrayHandle h, int dims, int pos)
{
    if (dims == 1)
        return svGetArrElemPtr1(h, svLow(h, 1) + pos);
    return svGetArrElemPtr2(h, svLow(h, 1) + pos / svSize(h, 2), svLow(h, 2) + pos % svSize(h, 2));
}

/* expected holds the element values in C order, each of size bytes. */
static void whole(const char *name, const svOpenArrayHandle h, int dims, const void *expected,
                  int size)
{
    char *base = (char *)svGetArrayPtr(h);
    int bytes = svSizeOfArray(h);
    int count = dims == 1 ? svSize(h, 1) : svSize(h, 1) * svSize(h, 2);
    int pos, layout_ok, elements_ok = 1;

    if (base == NULL) {
        layout_ok = bytes == 0;
    } else {
        layout_ok = bytes == count * size;
        for (pos = 0; pos < count; pos++)
            if ((void *)(base + pos * size) != element(h, dims, pos)
                || memcmp(base + pos * size, (const char *)expected + pos * size, size) != 0)
                layout_ok = 0;
    }
    for (pos = 0; pos < count; pos++) {
        void *e = element(h, dims, pos);
        if (e == NULL || memcmp(e, (const char *)expected + pos * size, size) != 0)
            elements_ok = 0;
    }
    printf("%s: whole array NULL and 0, or in C layout with its total size: %d\n", name,
           layout_ok);
    printf("%s: every element has an address holding its value: %d\n", name, elements_ok);
}

void c_whole(const svOpenArrayHandle a, const svOpenArrayHandle m, const svOpenArrayHandle r,
             const svOpenArrayHandle b)
{
    static const int av[4] = {33, 44, 55, 66};
    static const int mv[6] = {2, 3, 4, 12, 13, 14};
    static const double rv[3] = {0.25, 1.25, 2.25};
    static const char bv[5] = {-1, -2, -3, -4, -5};

    whole("a", a, 1, av, (int)sizeof(int));
    whole("m", m, 2, mv, (int)sizeof(int));
    whole("r", r, 1, rv, (int)sizeof(double));
    whole("b", b, 1, bv, (int)sizeof(char));
    fflush(stdout);
}

static void report(const char *name, int ok)
{
    printf("%s: each element address NULL or the representation of an individual value: %d\n",
           name, ok);
}

void c_repr(const svOpenArrayHandle p, const svOpenArrayHandle q, const svOpenArrayHandle s,
            const svOpenArrayHandle l, const svOpenArrayHandle w)
{
    static const svBitVecVal pv[3] = {0x40u, 0x81u, 0xc2u};       /* p[0] p[1] p[2] */
    static const svBitVecVal qa[2] = {0xac5u, 0x00fu};            /* q[1] q[2] aval */
    static const svBitVecVal qb[2] = {0x0f0u, 0xf0fu};            /* q[1] q[2] bval */
    static const svBit sv[4] = {1, 0, 0, 1};
    static const svLogic lv[4] = {sv_0, sv_1, sv_z, sv_x};
    static const svBitVecVal w0[2] = {0x3456789au, 0xdcba9876u};  /* w[0] w[1] */
    static const svBitVecVal w1[2] = {0x12u, 0xfeu};
    int k, ok;
    const void *e;

    for (ok = 1, k = 0; k <= 2; k++)
        if ((e = svGetArrElemPtr1(p, k)) != NULL && (*(const svBitVecVal *)e & 0xffu) != pv[k])
            ok = 0;
    report("p", ok);
    for (ok = 1, k = 1; k <= 2; k++) {
        const svLogicVecVal *v = (const svLogicVecVal *)svGetArrElemPtr1(q, k);
        if (v != NULL && ((v->aval & 0xfffu) != qa[k - 1] || (v->bval & 0xfffu) != qb[k - 1]))
            ok = 0;
    }
    report("q", ok);
    for (ok = 1, k = 0; k <= 3; k++)
        if ((e = svGetArrElemPtr1(s, k)) != NULL && *(const svBit *)e != sv[k])
            ok = 0;
    report("s", ok);
    for (ok = 1, k = 0; k <= 3; k++)
        if ((e = svGetArrElemPtr1(l, k)) != NULL && *(const svLogic *)e != lv[k])
            ok = 0;
    report("l", ok);
    for (ok = 1, k = 0; k <= 1; k++) {
        const svBitVecVal *v = (const svBitVecVal *)svGetArrElemPtr1(w, k);
        if (v != NULL && (v[0] != w0[k] || (v[1] & 0xffu) != w1[k]))
            ok = 0;
    }
    report("w", ok);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
