/* C side of test_svdpi_h_deprecated_portion_types (IEEE 1800-2023 35.3.2, I.3). */
#include "svdpi.h"
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

void dpi_check_deprecated_types(void)
{
    printf("SV_CANONICAL_SIZE of 1 32 33 64 65 is 1 1 2 2 3 %d\n",
           SV_CANONICAL_SIZE(1) == 1 && SV_CANONICAL_SIZE(32) == 1 &&
           SV_CANONICAL_SIZE(33) == 2 && SV_CANONICAL_SIZE(64) == 2 &&
           SV_CANONICAL_SIZE(65) == 3);
    printf("svBitVec32 is unsigned int %d\n", SAME_TYPE((svBitVec32)0, unsigned int));
    printf("svLogicVec32 is two unsigned ints c then d %d\n",
           sizeof(svLogicVec32) == 2 * sizeof(unsigned int) &&
           SAME_TYPE(((svLogicVec32 *)0)->c, unsigned int) &&
           SAME_TYPE(((svLogicVec32 *)0)->d, unsigned int) &&
           offsetof(svLogicVec32, c) < offsetof(svLogicVec32, d));
    printf("svBitPackedArrRef is void* %d\n", SAME_TYPE((svBitPackedArrRef)0, void*));
    printf("svLogicPackedArrRef is void* %d\n",
           SAME_TYPE((svLogicPackedArrRef)0, void*));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
