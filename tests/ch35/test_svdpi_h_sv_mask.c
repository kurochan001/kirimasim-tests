/* C side of test_svdpi_h_sv_mask (IEEE 1800-2023 35.3.2, H.10.1.2, I.3). */
#include "svdpi.h"
#include <stdio.h>
#include <string.h>

/* The replacement list of SV_MASK, made into a string by the preprocessor. */
#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)

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

void dpi_check_sv_mask(void)
{
    printf("SV_MASK(N) expands to (~(-1 << (N))) %d\n",
           strcmp(VT_XSTR(SV_MASK(N)), "(~(-1 << (N)))") == 0);
    printf("SV_MASK(5) has type int %d\n", SAME_TYPE(SV_MASK(5), int));
    printf("SV_MASK of 1 5 31 is 0x1 0x1f 0x7fffffff %d\n",
           SV_MASK(1) == 0x1 && SV_MASK(5) == 0x1f && SV_MASK(31) == 0x7fffffff);
    printf("SV_GET_UNSIGNED_BITS of 0x1234 with 4 is 0x4 %d\n",
           SV_GET_UNSIGNED_BITS(0x1234, 4) == 0x4);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
