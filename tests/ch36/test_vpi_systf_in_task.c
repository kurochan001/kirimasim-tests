/* VPI application of test_vpi_systf_in_task (IEEE 1800-2023 36.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int first_int(void)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg = it != NULL ? vpi_scan(it) : NULL;
    s_vpi_value v;

    if (arg == NULL)
        return 0;
    vpi_free_object(it);
    v.format = vpiIntVal;
    vpi_get_value(arg, &v);
    return (int)v.value.integer;
}

static PLI_INT32 note_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("note %d\n", first_int());
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("total %d\n", first_int());
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_note", note_calltf);
    add("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
