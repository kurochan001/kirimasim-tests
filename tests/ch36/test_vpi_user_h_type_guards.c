/* VPI application of test_vpi_user_h_type_guards (IEEE 1800-2023 36.7, K.2). */
/* The application's own types, marked as defined, before the header. */
#define PLI_TYPES
typedef long PLI_INT32;
typedef unsigned long PLI_UINT32;
typedef long PLI_INT16;
typedef unsigned long PLI_UINT16;
typedef signed char PLI_BYTE8;
typedef unsigned long PLI_UBYTE8;
#define SVPI_TYPES
typedef long double PLI_INT64;
typedef double PLI_UINT64;
#include "vpi_user.h"
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

static void show_all(void)
{
    printf("PLI_TYPES kept the application's PLI_INT32 to PLI_UBYTE8 %d\n",
           SAME_TYPE((PLI_INT32)0, long) && SAME_TYPE((PLI_UINT32)0, unsigned long)
           && SAME_TYPE((PLI_INT16)0, long) && SAME_TYPE((PLI_UINT16)0, unsigned long)
           && SAME_TYPE((PLI_BYTE8)0, signed char)
           && SAME_TYPE((PLI_UBYTE8)0, unsigned long));
    printf("SVPI_TYPES kept the application's PLI_INT64 and PLI_UINT64 %d\n",
           SAME_TYPE((PLI_INT64)0, long double) && SAME_TYPE((PLI_UINT64)0, double));
    printf("vpiHandle is a pointer to the application's PLI_UINT32 %d\n",
           SAME_TYPE((vpiHandle)0, unsigned long *));
    fflush(stdout);
}

void (*vlog_startup_routines[])(void) = {show_all, 0};

#ifdef __cplusplus
}
#endif
