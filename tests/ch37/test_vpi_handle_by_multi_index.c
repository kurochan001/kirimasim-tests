/* VPI application of test_vpi_handle_by_multi_index (IEEE 1800-2023 37.2.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_handle_by_multi_index"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void put_int(vpiHandle h, PLI_INT32 value)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = value;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    vpiHandle m = find("m"), bv = find("bv"), h;
    PLI_INT32 elem[2] = {1, 2}, bitsel[2] = {1, 5};
    const char *name;

    (void)cb;
    h = m != NULL ? vpi_handle_by_multi_index(m, 2, elem) : NULL;
    name = h != NULL ? vpi_get_str(vpiFullName, h) : NULL;
    vpi_printf((PLI_BYTE8 *)"m with {1, 2}: %s\n", h == NULL ? "NULL" : name != NULL ? name : "?");
    if (h != NULL)
        put_int(h, 42);

    h = bv != NULL ? vpi_handle_by_multi_index(bv, 2, bitsel) : NULL;
    vpi_printf((PLI_BYTE8 *)"bv with {1, 5}: handle %s\n", h != NULL ? "created" : "NULL");
    if (h != NULL)
        put_int(h, 1);
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
