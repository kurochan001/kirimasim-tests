/* C side of test_dpi_open_array_query_functions (IEEE 1800-2023 H.12.2). */
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

typedef int (*increment_t)(const svOpenArrayHandle, int);

static void show(const char *name, const svOpenArrayHandle h, int d)
{
    printf("%s dim %d: C left %d right %d low %d high %d increment %d size %d\n", name, d,
           svLeft(h, d), svRight(h, d), svLow(h, d), svHigh(h, d), svIncrement(h, d),
           svSize(h, d));
}

void c_query(const char *name, const svOpenArrayHandle h)
{
    show(name, h, 1);
    show(name, h, 2);
    show(name, h, 0);
    fflush(stdout);
}

void c_types(void)
{
    printf("svIncrement: int (const svOpenArrayHandle, int) %d\n",
           SAME_TYPE(&svIncrement, increment_t));
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
