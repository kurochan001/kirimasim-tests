/* VPI application of test_vpi_put_value_array (IEEE 1800-2023 38.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 fill_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle arr = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_put_value_array.arr", NULL);
    s_vpi_arrayvalue v;
    PLI_INT32 pair[2] = {11, 22}, seven[1] = {7};
    PLI_INT32 start1[1] = {1}, start3[1] = {3};

    (void)user_data;
    if (arr == NULL) {
        vpi_printf("arr not found\n");
        return 0;
    }
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    v.value.integers = pair;
    vpi_put_value_array(arr, &v, start1, 2);
    v.flags = vpiOneValue;
    v.value.integers = seven;
    vpi_put_value_array(arr, &v, start3, 2);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data s;
    memset(&s, 0, sizeof s);
    s.type = vpiSysTask;
    s.tfname = (PLI_BYTE8 *)"$vt_fill";
    s.calltf = fill_calltf;
    vpi_register_systf(&s);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
