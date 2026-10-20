/* VPI application of test_vpi_systf_no_arguments (IEEE 1800-2023 36.4, 38.23). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 count_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    int n = 0;

    (void)user_data;
    if (it == NULL) {
        vpi_printf("no arguments: the iterator is NULL\n");
        return 0;
    }
    while (vpi_scan(it) != NULL)
        n++;
    vpi_printf("%d argument%s\n", n, n == 1 ? "" : "s");
    return 0;
}

static PLI_INT32 next_calltf(PLI_BYTE8 *user_data)
{
    static int counter;
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = ++counter;
    vpi_put_value(vpi_handle(vpiSysTfCall, NULL), &v, NULL, vpiNoDelay);
    return 0;
}

static void add(const char *name, PLI_INT32 type, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = type == vpiSysFunc ? vpiIntFunc : 0;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_count", vpiSysTask, count_calltf);
    add("$vt_next", vpiSysFunc, next_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
