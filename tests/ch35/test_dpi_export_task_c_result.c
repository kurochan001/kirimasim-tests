/* C side of test_dpi_export_task_c_result (IEEE 1800-2023 35.8, H.8.2,
   35.9). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* The same C header as an import with the same result and formals (H.8.2):
   an exported task is an int function, an exported function returns its
   own result type. The input is passed by value, the output by pointer. */
extern int sv_step(int a, int *b);
extern int sv_scale(int a, int *b);

static int first_result = -1, first_out = -1, func_result = -1, func_out = -1;
static int second_result = -1, disabled = -1;

int c_run(void)
{
    int unused = 0;

    first_result = sv_step(1, &first_out);
    func_result = sv_scale(7, &func_out);
    second_result = sv_step(2, &unused);
    disabled = svIsDisabledState();
    /* A disabled imported task acknowledges the disable by returning 1. */
    return disabled ? 1 : 0;
}

void c_report(int *a, int *b, int *c, int *d, int *e, int *f)
{
    *a = first_result;
    *b = first_out;
    *c = func_result;
    *d = func_out;
    *e = second_result;
    *f = disabled;
}

#ifdef __cplusplus
}
#endif
