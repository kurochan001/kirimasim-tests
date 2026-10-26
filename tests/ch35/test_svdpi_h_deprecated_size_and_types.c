/* C side of test_svdpi_h_deprecated_size_and_types (IEEE 1800-2023 H.14.2). */
#include "svdpi.h"
#include <stddef.h>
#include <stdint.h>
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

void dpi_check_deprecated_types(void)
{
    printf("chunks of 1 31 32 33 63 64 65 96 97 128 bits %d %d %d %d %d %d %d %d %d %d\n",
           SV_CANONICAL_SIZE(1), SV_CANONICAL_SIZE(31), SV_CANONICAL_SIZE(32),
           SV_CANONICAL_SIZE(33), SV_CANONICAL_SIZE(63), SV_CANONICAL_SIZE(64),
           SV_CANONICAL_SIZE(65), SV_CANONICAL_SIZE(96), SV_CANONICAL_SIZE(97),
           SV_CANONICAL_SIZE(128));
    printf("svBitVec32 is uint32_t %d\n",
           SAME_TYPE((svBitVec32)0, uint32_t) && sizeof(svBitVec32) == 4);
    printf("svLogicVec32 is c then d, two unsigned int %d\n",
           SAME_TYPE(((svLogicVec32 *)0)->c, unsigned int) &&
           SAME_TYPE(((svLogicVec32 *)0)->d, unsigned int) &&
           offsetof(svLogicVec32, c) == 0 &&
           offsetof(svLogicVec32, d) == sizeof(unsigned int) &&
           sizeof(svLogicVec32) == 2 * sizeof(unsigned int));
    printf("svBitPackedArrRef is void* %d\n",
           SAME_TYPE((svBitPackedArrRef)0, void *));
    printf("svLogicPackedArrRef is void* %d\n",
           SAME_TYPE((svLogicPackedArrRef)0, void *));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
