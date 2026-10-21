/* VPI application of test_vpi_compare_objects_variable_select (IEEE 1800-2023 38.3). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "test_vpi_compare_objects_variable_select.%s", name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static PLI_INT32 compare_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle word = it ? vpi_scan(it) : NULL;
    vpiHandle bit = word ? vpi_scan(it) : NULL;
    vpiHandle mem = by_name("mem"), r = by_name("r"), j = by_name("j");
    s_vpi_value v;

    (void)user_data;
    if (bit == NULL || mem == NULL || r == NULL || j == NULL) {
        vpi_printf("objects not found\n");
        return 0;
    }
    vpi_release_handle(it);
    v.format = vpiIntVal;
    vpi_get_value(j, &v);
    vpi_printf("j=%d: mem[j] and mem[0]: %d, mem[j] and mem[1]: %d, r[j] and r[0]: %d, "
               "r[j] and r[1]: %d\n", (int)v.value.integer,
               (int)vpi_compare_objects(word, vpi_handle_by_index(mem, 0)),
               (int)vpi_compare_objects(word, vpi_handle_by_index(mem, 1)),
               (int)vpi_compare_objects(bit, vpi_handle_by_index(r, 0)),
               (int)vpi_compare_objects(bit, vpi_handle_by_index(r, 1)));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_compare";
    d.calltf = compare_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
