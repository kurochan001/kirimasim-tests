/* VPI application of test_vpi_put_value_array_order (IEEE 1800-2023 38.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static void fill(const char *name, PLI_INT32 first, PLI_INT32 second, PLI_INT32 *values,
                 PLI_UINT32 num)
{
    char full[96];
    vpiHandle array;
    PLI_INT32 index[2];
    s_vpi_arrayvalue av;

    snprintf(full, sizeof full, "test_vpi_put_value_array_order.%s", name);
    array = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (array == NULL) {
        vpi_printf("%s not found\n", name);
        return;
    }
    index[0] = first;
    index[1] = second;
    memset(&av, 0, sizeof av);
    av.format = vpiIntVal;
    av.value.integers = values;
    vpi_put_value_array(array, &av, index, num);
}

static PLI_INT32 on_start(p_cb_data data)
{
    static PLI_INT32 four[4] = {11, 22, 33, 44};
    static PLI_INT32 three[3] = {1, 2, 3};

    (void)data;
    fill("g", 1, 1, four, 4);
    fill("h", 0, 2, three, 3);
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
