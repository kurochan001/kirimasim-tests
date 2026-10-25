/* C side of test_dpi_canonical_aval_bval_packed_kinds (IEEE 1800-2023 H.2, H.7.7). */
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

static void chunk(const char *name, const svLogicVecVal *v, int k, unsigned mask)
{
    printf("%s chunk %d: aval %08x bval %08x\n", name, k, (unsigned)(v[k].aval & mask),
           (unsigned)(v[k].bval & mask));
}

void c_canon(const svLogicVecVal *l40, const svLogicVecVal *ps, const svLogicVecVal *pu,
             const svLogicVecVal *ig, const svLogicVecVal *tm, const svLogicVecVal *la,
             const svBitVecVal *b36, const svLogicVecVal *l36, svLogicVecVal *ol)
{
    svLogicVecVal *p = ol;

    printf("svLogicVecVal is s_vpi_vecval: %d\n", SAME_TYPE(p, s_vpi_vecval *));
    chunk("l40", l40, 0, 0xffffffffu);
    chunk("l40", l40, 1, 0xffu);
    chunk("ps", ps, 0, 0xfffu);
    chunk("pu", pu, 0, 0xffu);
    chunk("integer", ig, 0, 0xffffffffu);
    chunk("time", tm, 0, 0xffffffffu);
    chunk("time", tm, 1, 0xffffffffu);
    chunk("la", la, 0, 0xfffu);
    printf("b36 chunks %08x %01x, l36 aval %08x %01x bval %08x %01x\n", (unsigned)b36[0],
           (unsigned)(b36[1] & 0xfu), (unsigned)l36[0].aval, (unsigned)(l36[1].aval & 0xfu),
           (unsigned)l36[0].bval, (unsigned)(l36[1].bval & 0xfu));
    printf("2-state chunks equal the aval chunks: %d\n",
           b36[0] == l36[0].aval && (b36[1] & 0xfu) == (l36[1].aval & 0xfu));
    printf("svGetBitselLogic l40 bits 39 37 36: %d %d %d, svGetBitselBit b36 bit 35: %d\n",
           (int)svGetBitselLogic(l40, 39), (int)svGetBitselLogic(l40, 37),
           (int)svGetBitselLogic(l40, 36), (int)svGetBitselBit(b36, 35));
    ol->aval = 0x0fu;
    ol->bval = 0x33u;
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
