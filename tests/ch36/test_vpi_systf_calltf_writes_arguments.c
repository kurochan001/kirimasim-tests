/* VPI application of test_vpi_systf_calltf_writes_arguments (IEEE 1800-2023 36.8.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 int_of(vpiHandle object)
{
    s_vpi_value v;

    v.format = vpiIntVal;
    v.value.integer = 0;
    if (object != NULL)
        vpi_get_value(object, &v);
    return v.value.integer;
}

static void put_int(vpiHandle object, PLI_INT32 value)
{
    s_vpi_value v;

    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(object, &v, NULL, vpiNoDelay);
}

static PLI_INT32 add_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle target = it != NULL ? vpi_scan(it) : NULL;
    vpiHandle amount = it != NULL ? vpi_scan(it) : NULL;

    (void)user_data;
    if (target == NULL || amount == NULL)
        return 0;
    vpi_free_object(it);
    put_int(target, int_of(target) + int_of(amount));
    return 0;
}

static PLI_INT32 set_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle target = it != NULL ? vpi_scan(it) : NULL;
    vpiHandle value = it != NULL ? vpi_scan(it) : NULL;

    (void)user_data;
    if (target == NULL || value == NULL)
        return 0;
    vpi_free_object(it);
    put_int(target, int_of(value));
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
    add("$vt_add", add_calltf);
    add("$vt_set", set_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
