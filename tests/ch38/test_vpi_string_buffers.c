/* VPI application of test_vpi_string_buffers (IEEE 1800-2023 38.11, 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_BYTE8 *bin_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiBinStrVal;
    vpi_get_value(h, &v);
    return v.value.str;
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    vpiHandle alpha = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_string_buffers.alpha", NULL);
    vpiHandle beta = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_string_buffers.beta", NULL);
    PLI_BYTE8 *kept;
    char copy[2][32];

    (void)cb;
    if (alpha == NULL || beta == NULL) {
        vpi_printf((PLI_BYTE8 *)"objects not found\n");
        return 0;
    }

    kept = vpi_get_str(vpiName, alpha);
    strcpy(copy[0], kept);
    bin_value(beta);
    strcpy(copy[1], kept);
    vpi_get_str(vpiName, beta);
    vpi_printf((PLI_BYTE8 *)"vpi_get_str of alpha: '%s', after vpi_get_value of beta: '%s', "
               "after vpi_get_str of beta: '%s'\n", copy[0], copy[1], kept);

    kept = bin_value(alpha);
    strcpy(copy[0], kept);
    vpi_get_str(vpiName, beta);
    strcpy(copy[1], kept);
    bin_value(beta);
    vpi_printf((PLI_BYTE8 *)"vpi_get_value of alpha: '%s', after vpi_get_str of beta: '%s', "
               "after vpi_get_value of beta: '%s'\n", copy[0], copy[1], kept);
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time delay;
    s_cb_data cb;

    (void)data;
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &delay;
    vpi_register_cb(&cb);
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
