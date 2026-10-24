/* C side of test_dpi_svdpi_scalar_and_chunk_types (IEEE 1800-2023 H.10.1.1, H.10.1.2, H.7.7). */
#include "svdpi.h"
/* What the preprocessor sees right after the header. */
#ifdef VPI_VECVAL
#define VECVAL_DEFINED 1
#else
#define VECVAL_DEFINED 0
#endif
#include <stddef.h>
#include <stdio.h>

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

#define CHECK(what, ok) printf("%s %d\n", what, (int)(ok))

void c_check_types(void)
{
    const uint32_t v = 0xabcd1234u;

    CHECK("svScalar is unsigned char", SAME_TYPE((svScalar)0, unsigned char));
    CHECK("svBit and svLogic are svScalar",
          SAME_TYPE((svBit)0, svScalar) && SAME_TYPE((svLogic)0, svScalar));
    printf("sv_0 sv_1 sv_z sv_x: %d %d %d %d\n", sv_0, sv_1, sv_z, sv_x);
    CHECK("svBitVecVal is uint32_t", SAME_TYPE((svBitVecVal)0, uint32_t));
    CHECK("VPI_VECVAL defined", VECVAL_DEFINED);
    CHECK("t_vpi_vecval aliases s_vpi_vecval p_vpi_vecval",
          SAME_TYPE((s_vpi_vecval *)0, struct t_vpi_vecval *) &&
          SAME_TYPE((p_vpi_vecval)0, struct t_vpi_vecval *));
    CHECK("t_vpi_vecval aval bval uint32_t in this order",
          SAME_TYPE(((s_vpi_vecval *)0)->aval, uint32_t) &&
          SAME_TYPE(((s_vpi_vecval *)0)->bval, uint32_t) &&
          offsetof(s_vpi_vecval, aval) < offsetof(s_vpi_vecval, bval));
    CHECK("svLogicVecVal is s_vpi_vecval", SAME_TYPE((svLogicVecVal *)0, s_vpi_vecval *));
    printf("SV_PACKED_DATA_NELEMS of 0 1 32 33 64 65: %d %d %d %d %d %d\n",
           (int)SV_PACKED_DATA_NELEMS(0), (int)SV_PACKED_DATA_NELEMS(1),
           (int)SV_PACKED_DATA_NELEMS(32), (int)SV_PACKED_DATA_NELEMS(33),
           (int)SV_PACKED_DATA_NELEMS(64), (int)SV_PACKED_DATA_NELEMS(65));
    printf("SV_GET_UNSIGNED_BITS of 0x%x with 32 16 8 1: 0x%x 0x%x 0x%x 0x%x\n", (unsigned)v,
           (unsigned)SV_GET_UNSIGNED_BITS(v, 32), (unsigned)SV_GET_UNSIGNED_BITS(v, 16),
           (unsigned)SV_GET_UNSIGNED_BITS(v, 8), (unsigned)SV_GET_UNSIGNED_BITS(v, 1));
    fflush(stdout);
}

void c_words(const svBitVecVal *b, const svLogicVecVal *l)
{
    int n = SV_PACKED_DATA_NELEMS(40);

    printf("bit [39:0] in %d chunks: chunk 0 %08x, chunk 1 %02x\n", n, (unsigned)b[0],
           (unsigned)SV_GET_UNSIGNED_BITS(b[1], 8));
    printf("logic [39:0] in %d chunks: chunk 0 aval %08x bval %08x, chunk 1 aval %02x bval %02x\n",
           n, (unsigned)l[0].aval, (unsigned)l[0].bval,
           (unsigned)SV_GET_UNSIGNED_BITS(l[1].aval, 8),
           (unsigned)SV_GET_UNSIGNED_BITS(l[1].bval, 8));
    fflush(stdout);
}

void c_make(svBitVecVal *b, svLogicVecVal *l)
{
    b[0] = 0x89abcdefu;
    b[1] = 0x01u;
    l[0].aval = 0x13579bdfu;
    l[0].bval = 0;
    l[1].aval = 0xe2u;
    l[1].bval = 0;
}

#ifdef __cplusplus
}
#endif
