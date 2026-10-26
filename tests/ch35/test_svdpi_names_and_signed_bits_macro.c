/* C side of test_svdpi_names_and_signed_bits_macro (IEEE 1800-2023 H.3, H.10, H.10.1.2). */
#include <stdint.h>
#include <stdio.h>
#include "svdpi.h"

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

void dpi_names(void)
{
    printf("names %d %d %d %d %d\n",
           SAME_TYPE((svBit)0, uint8_t) && SAME_TYPE((svLogic)0, uint8_t),
           SAME_TYPE((svScope)0, void *) && SAME_TYPE((svOpenArrayHandle)0, void *),
           SAME_TYPE(&svGetScope, svScope (*)(void)),
           sv_0 == 0 && sv_1 == 1 && sv_z == 2 && sv_x == 3,
           SV_PACKED_DATA_NELEMS(33) == 2);
    printf("mask %u %u\n", (unsigned)SV_MASK(5),
           (unsigned)SV_GET_UNSIGNED_BITS(0x12345678u, 8));
    printf("signed %u %u %u\n",
           (unsigned)SV_GET_SIGNED_BITS(0x0000007Fu, 8),
           (unsigned)SV_GET_SIGNED_BITS(0x00000180u, 8),
           (unsigned)SV_GET_SIGNED_BITS(0x80000000u, 32));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
