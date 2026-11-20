/* C side of test_dpi_context_import_optimization_barrier (IEEE 1800-2023 35.5.3).
   The context imports reach x only through the exported functions; the
   noncontext import touches only its arguments. */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_get_x(void);
extern void sv_set_x(int v);

int c_swap_x(int v)
{
    int old = sv_get_x();
    sv_set_x(v);
    return old;
}

void c_bump_x(void)
{
    sv_set_x(sv_get_x() + 5);
}

void c_args_only(int a, int *o, int *io)
{
    *o = a * 2;
    *io = *io + a;
}

#ifdef __cplusplus
}
#endif
