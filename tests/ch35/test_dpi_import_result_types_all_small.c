/* C side of test_dpi_import_result_types_all_small
   (IEEE 1800-2023 35.5.5, H.7.4, A.10 footnote 26). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int stored;
static int handle_target;

void dpi_r_set(int v) { stored = v; }
int dpi_r_get(void) { return stored; }
char dpi_r_byte(int v) { return (char)(-40 * v); }
short dpi_r_short(int v) { return (short)(-10000 * v); }
int dpi_r_int(int v) { return 100000 * v; }
long long dpi_r_long(int v) { return (long long)v << 40; }
double dpi_r_real(int v) { return v + 0.125; }
float dpi_r_sreal(int v) { return (float)v * 0.5f; }

void *dpi_r_handle(int v)
{
    handle_target = v;
    return &handle_target;
}

int dpi_r_deref(void *p) { return *(int *)p; }

const char *dpi_r_str(int which)
{
    static const char *names[] = {"first", "second"};
    return names[which];
}

svBit dpi_r_bit(int v) { return (svBit)(v & 1); }
svLogic dpi_r_logic(int v) { return (v & 1) ? sv_1 : sv_0; }

#ifdef __cplusplus
}
#endif
