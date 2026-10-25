/* C side of test_svdpi_h_macros_and_c_linkage (IEEE 1800-2023 35.3.2, I.3). */
/* What the preprocessor sees before the header is included. */
#ifdef DPI_DLLISPEC
#define BEFORE_DLLISPEC 1
#else
#define BEFORE_DLLISPEC 0
#endif
#ifdef DPI_DLLESPEC
#define BEFORE_DLLESPEC 1
#else
#define BEFORE_DLLESPEC 0
#endif
#ifdef DPI_PROTOTYPES
#define BEFORE_PROTOTYPES 1
#else
#define BEFORE_PROTOTYPES 0
#endif
#include "svdpi.h"
/* What the preprocessor sees after the header is processed. */
#ifdef DPI_PROTOTYPES
#define AFTER_PROTOTYPES 1
#else
#define AFTER_PROTOTYPES 0
#endif
#ifdef XXTERN
#define AFTER_XXTERN 1
#else
#define AFTER_XXTERN 0
#endif
#ifdef EETERN
#define AFTER_EETERN 1
#else
#define AFTER_EETERN 0
#endif
#ifdef DPI_EXTERN
#define AFTER_EXTERN 1
#else
#define AFTER_EXTERN 0
#endif
/* The replacement list of the two DLL macros, made into a string. */
#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)
#define DPI_DLLISPEC_TEXT VT_XSTR(DPI_DLLISPEC)
#define DPI_DLLESPEC_TEXT VT_XSTR(DPI_DLLESPEC)
/* The scalar constants as C integer constant expressions. */
enum {
    VT_SV_0 = sv_0,
    VT_SV_1 = sv_1,
    VT_SV_Z = sv_z,
    VT_SV_X = sv_x
};
#ifdef __cplusplus
/* A header that did not put its declarations inside extern "C" would make
   these three redeclarations a conflict, so this file would not compile. */
extern "C" {
const char* svDpiVersion(void);
void svAckDisabledState(void);
svScope svGetScope(void);
}
#endif
#include <stdio.h>
#include <string.h>

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

void dpi_check_macros(void)
{
    printf("DPI_DLLISPEC and DPI_DLLESPEC undefined before the header %d\n",
           !BEFORE_DLLISPEC && !BEFORE_DLLESPEC);
    printf("DPI_DLLISPEC has an empty replacement here %d\n",
           DPI_DLLISPEC_TEXT[0] == '\0');
    printf("DPI_DLLESPEC has an empty replacement here %d\n",
           DPI_DLLESPEC_TEXT[0] == '\0');
    printf("DPI_PROTOTYPES not defined before the header %d\n", !BEFORE_PROTOTYPES);
    printf("DPI_PROTOTYPES XXTERN EETERN DPI_EXTERN gone after the header %d\n",
           !AFTER_PROTOTYPES && !AFTER_XXTERN && !AFTER_EETERN && !AFTER_EXTERN);
    printf("the routines decorated with XXTERN are callable prototypes %d\n",
           svDpiVersion() != NULL);
    printf("sv_0 sv_1 sv_z sv_x are 0 1 2 3 %d\n",
           VT_SV_0 == 0 && VT_SV_1 == 1 && VT_SV_Z == 2 && VT_SV_X == 3 && sv_0 == 0 &&
           sv_1 == 1 && sv_z == 2 && sv_x == 3);
    printf("svScope is void* %d\n", SAME_TYPE((svScope)0, void*));
    printf("svOpenArrayHandle is void* %d\n",
           SAME_TYPE((svOpenArrayHandle)0, void*));
    printf("a C++ translation unit can redeclare routines with C linkage %d\n", 1);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
