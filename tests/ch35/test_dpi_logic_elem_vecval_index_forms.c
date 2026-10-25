/* C side of test_dpi_logic_elem_vecval_index_forms (IEEE 1800-2023 H.12.5). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void clear(svLogicVecVal *v)
{
    v[0].aval = v[0].bval = v[1].aval = v[1].bval = 0x55555555u;
}

static void show(const char *what, const svLogicVecVal *v)
{
    printf("%s: chunk1 aval %03x bval %03x, chunk0 aval %08x bval %08x\n", what,
           (unsigned)(v[1].aval & 0xfffu), (unsigned)(v[1].bval & 0xfffu), (unsigned)v[0].aval,
           (unsigned)v[0].bval);
}

static void set(svLogicVecVal *v, unsigned a1, unsigned b1, unsigned a0, unsigned b0)
{
    v[1].aval = a1;
    v[1].bval = b1;
    v[0].aval = a0;
    v[0].bval = b0;
}

void c_logic_elems(const svOpenArrayHandle a1, const svOpenArrayHandle a2,
                   const svOpenArrayHandle a3)
{
    svLogicVecVal v[2];

    clear(v);
    svGetLogicArrElem1VecVal(v, a1, 5);
    show("svGetLogicArrElem1VecVal a1[5]", v);
    clear(v);
    svGetLogicArrElemVecVal(v, a1, 4);
    show("svGetLogicArrElemVecVal a1[4]", v);
    clear(v);
    svGetLogicArrElem2VecVal(v, a2, 2, 3);
    show("svGetLogicArrElem2VecVal a2[2][3]", v);
    clear(v);
    svGetLogicArrElemVecVal(v, a2, 1, 4);
    show("svGetLogicArrElemVecVal a2[1][4]", v);
    clear(v);
    svGetLogicArrElem3VecVal(v, a3, 1, 0, 7);
    show("svGetLogicArrElem3VecVal a3[1][0][7]", v);
    clear(v);
    svGetLogicArrElemVecVal(v, a3, 2, 1, 6);
    show("svGetLogicArrElemVecVal a3[2][1][6]", v);

    /* 44'h5z1x111z003 */
    set(v, 0x501u, 0x0f0u, 0xf1110003u, 0xf000f000u);
    svPutLogicArrElem1VecVal(a1, v, 3);
    /* 44'hx5a2222z0x5 */
    set(v, 0xf5au, 0xf00u, 0x222200f5u, 0x0000f0f0u);
    svPutLogicArrElemVecVal(a1, v, 5);
    /* 44'h5z23333x0z3 */
    set(v, 0x502u, 0x0f0u, 0x3333f003u, 0x0000f0f0u);
    svPutLogicArrElem2VecVal(a2, v, 1, 3);
    /* 44'hz5bx4444z24 */
    set(v, 0x05bu, 0xf00u, 0xf4444024u, 0xf0000f00u);
    svPutLogicArrElemVecVal(a2, v, 2, 4);
    /* 44'h53x5555z2x6 */
    set(v, 0x53fu, 0x00fu, 0x555502f6u, 0x0000f0f0u);
    svPutLogicArrElem3VecVal(a3, v, 2, 0, 6);
    /* 44'h5cz666x6z17 */
    set(v, 0x5c0u, 0x00fu, 0x666f6017u, 0x000f0f00u);
    svPutLogicArrElemVecVal(a3, v, 1, 1, 7);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
