/* VPI application of test_vpi_get_vlog_info_plusargs (IEEE 1800-2023 38.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 on_start(p_cb_data data)
{
    s_vpi_vlog_info info;
    PLI_INT32 ok;
    int k, alpha = -1, count = -1, strings = 1;

    (void)data;
    memset(&info, 0, sizeof info);
    ok = vpi_get_vlog_info(&info);
    for (k = 0; k < info.argc && info.argv != NULL; k++) {
        if (info.argv[k] == NULL)
            strings = 0;
        else if (strcmp(info.argv[k], "+vt_alpha") == 0)
            alpha = k;
        else if (strcmp(info.argv[k], "+vt_count=3") == 0)
            count = k;
    }
    vpi_printf("vpi_get_vlog_info returns %d, all argc entries are strings: %s\n", (int)ok,
               strings && info.argv != NULL ? "yes" : "no");
    vpi_printf("+vt_alpha in argv: %s, +vt_count=3 in argv: %s\n", alpha > 0 ? "yes" : "no",
               count > 0 ? "yes" : "no");
    vpi_printf("+vt_alpha comes before +vt_count=3: %s\n",
               alpha > 0 && count > alpha ? "yes" : "no");
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
