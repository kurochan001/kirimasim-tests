/* VPI application of test_generate_unnamed_block_external_names (IEEE 1800-2023 27.6). */
#include <stdio.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_generate_unnamed_block_external_names"

static const char *const names[] = {
    "genblk1.p",
    "genblk1.q",
    "lp[1].genblk1.r",
    "lp[0].genblk1.r",
    "genblk3.s",
    "genblk03.s",
    "genblk003.s",
    "genblk2.r",
    "genblk4[0].t",
    "genblk4[1].t",
    "genblk3[1].t",
};

static void look_up(const char *name)
{
    char full[128];
    vpiHandle h;
    s_vpi_value v;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name(full, NULL);
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    vpi_printf((PLI_BYTE8 *)"%s: found, value %d\n", name, (int)v.value.integer);
}

static PLI_INT32 on_start(p_cb_data data)
{
    size_t k;
    (void)data;
    for (k = 0; k < sizeof names / sizeof names[0]; k++)
        look_up(names[k]);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    d.obj = NULL;
    d.time = NULL;
    d.value = NULL;
    d.index = 0;
    d.user_data = NULL;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
