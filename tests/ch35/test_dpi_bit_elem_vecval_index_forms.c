/* C side of test_dpi_bit_elem_vecval_index_forms (IEEE 1800-2023 H.12.5). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void clear(svBitVecVal *v) { v[0] = v[1] = 0x55555555u; }

static void show(const char *what, const svBitVecVal *v)
{
    printf("%s: chunk1 %02x chunk0 %08x\n", what, (unsigned)(v[1] & 0xffu), (unsigned)v[0]);
}

static void set(svBitVecVal *v, unsigned hi, unsigned lo)
{
    v[0] = lo;
    v[1] = hi;
}

void c_bit_elems(const svOpenArrayHandle a1, const svOpenArrayHandle a2,
                 const svOpenArrayHandle a3)
{
    svBitVecVal v[2];

    clear(v);
    svGetBitArrElem1VecVal(v, a1, 5);
    show("svGetBitArrElem1VecVal a1[5]", v);
    clear(v);
    svGetBitArrElemVecVal(v, a1, 4);
    show("svGetBitArrElemVecVal a1[4]", v);
    clear(v);
    svGetBitArrElem2VecVal(v, a2, 2, 3);
    show("svGetBitArrElem2VecVal a2[2][3]", v);
    clear(v);
    svGetBitArrElemVecVal(v, a2, 1, 4);
    show("svGetBitArrElemVecVal a2[1][4]", v);
    clear(v);
    svGetBitArrElem3VecVal(v, a3, 1, 0, 7);
    show("svGetBitArrElem3VecVal a3[1][0][7]", v);
    clear(v);
    svGetBitArrElemVecVal(v, a3, 2, 1, 6);
    show("svGetBitArrElemVecVal a3[2][1][6]", v);

    set(v, 0x51u, 0x11110003u);
    svPutBitArrElem1VecVal(a1, v, 3);
    set(v, 0x5au, 0x22220005u);
    svPutBitArrElemVecVal(a1, v, 5);
    set(v, 0x52u, 0x33330013u);
    svPutBitArrElem2VecVal(a2, v, 1, 3);
    set(v, 0x5bu, 0x44440024u);
    svPutBitArrElemVecVal(a2, v, 2, 4);
    set(v, 0x53u, 0x55550206u);
    svPutBitArrElem3VecVal(a3, v, 2, 0, 6);
    set(v, 0x5cu, 0x66660117u);
    svPutBitArrElemVecVal(a3, v, 1, 1, 7);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
