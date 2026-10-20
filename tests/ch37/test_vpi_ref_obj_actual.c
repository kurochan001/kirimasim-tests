/* VPI application of test_vpi_ref_obj_actual (IEEE 1800-2023 37.15, 37.14). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_ref_obj_actual"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "none";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 ref_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle u = find("u");
    vpiHandle it = u ? vpi_iterate(vpiPort, u) : NULL, port;

    (void)user_data;
    while (it != NULL && (port = vpi_scan(it)) != NULL) {
        vpiHandle low = vpi_handle(vpiLowConn, port);
        vpiHandle actual = low ? vpi_handle(vpiActual, low) : NULL;
        vpi_printf((PLI_BYTE8 *)"port %s: low connection is %s named %s, actual %s = %d\n",
                   name_of(port),
                   low && vpi_get(vpiType, low) == vpiRefObj ? "a ref obj" : "another object",
                   name_of(low), actual ? vpi_get_str(vpiFullName, actual) : "none",
                   actual ? int_value(actual) : -1);
    }
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
    add("$vt_ref", ref_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
