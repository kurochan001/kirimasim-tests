/* VPI application of test_vpi_net_array_deposit (IEEE 1800-2023 38.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_array_deposit"

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle wa = vpi_handle_by_name((PLI_BYTE8 *)TOP ".wa", NULL);
    s_vpi_arrayvalue v;
    PLI_INT32 index[1];
    PLI_INT32 value[1];

    (void)cb;
    if (wa == NULL) {
        vpi_printf((PLI_BYTE8 *)"the net array is missing\n");
        return 0;
    }
    value[0] = 0xaa;
    memset(&v, 0, sizeof v);
    v.format = (PLI_UINT32)vpiIntVal;
    v.value.integers = value;
    index[0] = 0;
    vpi_put_value_array(wa, &v, index, 1);
    return 0;
}

static void register_all(void)
{
    static s_vpi_time when;
    s_cb_data cb;

    when.type = vpiSimTime;
    when.high = 0;
    when.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &when;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = { register_all, 0 };

#ifdef __cplusplus
}
#endif
