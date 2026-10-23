/* C side of test_svdpi_h_after_vpi_user_h (IEEE 1800-2023 35.3.2, I.3). */
#include "vpi_user.h"
#include "svdpi.h"
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

void dpi_check_after_vpi_user(void)
{
    printf("svTimeVal is the s_vpi_time of vpi_user.h %d\n",
           SAME_TYPE((svTimeVal *)0, s_vpi_time *)
           && SAME_TYPE(((svTimeVal *)0)->high, PLI_UINT32));
    printf("svLogicVecVal is the s_vpi_vecval of vpi_user.h %d\n",
           SAME_TYPE((svLogicVecVal *)0, s_vpi_vecval *)
           && SAME_TYPE(((svLogicVecVal *)0)->aval, PLI_UINT32));
    printf("vpiScaledRealTime vpiSimTime vpiSuppressTime are 1 2 3 %d\n",
           vpiScaledRealTime == 1 && vpiSimTime == 2 && vpiSuppressTime == 3);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
