/* VPI application of test_vpi_module_config_name (IEEE 1800-2023 33.7). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_module_config_name"

static void report(const char *name)
{
    char full[128];
    vpiHandle h;
    const char *s;
    char cell[64];

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    s = vpi_get_str(vpiCell, h);
    snprintf(cell, sizeof cell, "%s", s != NULL ? s : "NULL");
    s = vpi_get_str(vpiConfig, h);
    vpi_printf((PLI_BYTE8 *)"%s: cell %s, config %s\n", name, cell, s != NULL ? s : "NULL");
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    report("u");
    report("v");
    report("m.leaf");
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
