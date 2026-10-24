/* VPI application of test_vpi_compare_objects_current_object (IEEE 1800-2023 38.3). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_compare_objects_current_object"

static int int_of(const char *name)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    s_vpi_value v;

    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 compare_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle first = it ? vpi_scan(it) : NULL;
    vpiHandle second = first ? vpi_scan(it) : NULL;
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem", NULL);
    vpiHandle mem0 = mem ? vpi_handle_by_index(mem, 0) : NULL;

    (void)user_data;
    if (second == NULL || mem0 == NULL) {
        vpi_printf("objects not found\n");
        return 0;
    }
    vpi_release_handle(it);
    vpi_printf("j=%d k=%d: mem[j] and mem[k] %d, mem[j] and itself %d, mem[j] and mem[0] %d\n",
               int_of(TOP ".j"), int_of(TOP ".k"), (int)vpi_compare_objects(first, second),
               (int)vpi_compare_objects(first, first), (int)vpi_compare_objects(first, mem0));
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
