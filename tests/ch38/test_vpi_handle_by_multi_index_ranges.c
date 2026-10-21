/* VPI application of test_vpi_handle_by_multi_index_ranges (IEEE 1800-2023 38.20). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void write_through(vpiHandle array, const char *label, PLI_INT32 n, PLI_INT32 i0,
                          PLI_INT32 i1, PLI_INT32 i2, PLI_INT32 i3, PLI_INT32 i4, int value)
{
    PLI_INT32 index[5];
    vpiHandle h;
    s_vpi_value v;

    index[0] = i0;
    index[1] = i1;
    index[2] = i2;
    index[3] = i3;
    index[4] = i4;
    h = array ? vpi_handle_by_multi_index(array, n, index) : NULL;
    vpi_printf("%s: %s\n", label, h ? "handle" : "NULL");
    if (h == NULL)
        return;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle m = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_handle_by_multi_index_ranges.m", NULL);
    vpiHandle c = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_handle_by_multi_index_ranges.c", NULL);

    (void)data;
    write_through(m, "m[-1][5]", 2, -1, 5, 0, 0, 0, 0x11);
    write_through(m, "m[2][4]", 2, 2, 4, 0, 0, 0, 0x22);
    write_through(m, "m[0][4][7]", 3, 0, 4, 7, 0, 0, 1);
    write_through(c, "c[0][1][2]", 3, 0, 1, 2, 0, 0, 1000);
    write_through(c, "c[1][0][3][4]", 4, 1, 0, 3, 4, 0, 1);
    write_through(c, "c[0][1][2][5][0]", 5, 0, 1, 2, 5, 0, 1);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
