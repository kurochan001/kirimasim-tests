/* VPI application of test_vpi_static_handle_lifetime (IEEE 1800-2023 37.2.4, 37.3.7). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_static_handle_lifetime"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static vpiHandle kept;

static PLI_INT32 keep_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    kept = find("count");
    return 0;
}

static PLI_INT32 use_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle fresh = find("count");
    int same, r1, r2;

    (void)user_data;
    if (kept == NULL || fresh == NULL) {
        vpi_printf((PLI_BYTE8 *)"count not found\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"kept handle reads %d\n", int_value(kept));
    same = (int)vpi_compare_objects(kept, fresh);
    r1 = (int)vpi_release_handle(fresh);
    r2 = (int)vpi_release_handle(kept);
    vpi_printf((PLI_BYTE8 *)"same object as a new handle: %d, released: %d %d\n", same, r1, r2);
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
    add("$vt_keep", keep_calltf);
    add("$vt_use", use_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
