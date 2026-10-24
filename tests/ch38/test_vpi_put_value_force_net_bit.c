/* VPI application of test_vpi_put_value_force_net_bit (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle m_obj, bit_obj;

static int read_int(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 at_15(p_cb_data cb)
{
    s_vpi_value v;

    (void)cb;
    v.format = vpiIntVal;
    v.value.integer = 1;
    vpi_put_value(bit_obj, &v, NULL, vpiForceFlag);
    vpi_printf((PLI_BYTE8 *)"15: after vpiForceFlag of m[0] to 1, m=%d\n", read_int(m_obj));
    return 0;
}

static PLI_INT32 at_25(p_cb_data cb)
{
    s_vpi_value v;

    (void)cb;
    v.format = vpiIntVal;
    v.value.integer = -1;
    vpi_put_value(bit_obj, &v, NULL, vpiReleaseFlag);
    vpi_printf((PLI_BYTE8 *)"25: vpiReleaseFlag of m[0] gives %d in value_p, m=%d\n",
               (int)v.value.integer, read_int(m_obj));
    return 0;
}

static void after(PLI_UINT32 delay, PLI_INT32 (*rtn)(p_cb_data))
{
    static s_vpi_time times[2];
    static int used = 0;
    s_cb_data cb;

    times[used].type = vpiSimTime;
    times[used].high = 0;
    times[used].low = delay;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = rtn;
    cb.time = &times[used++];
    vpi_register_cb(&cb);
}

static PLI_INT32 on_start(p_cb_data data)
{
    (void)data;
    m_obj = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_put_value_force_net_bit.m", NULL);
    bit_obj = m_obj ? vpi_handle_by_index(m_obj, 0) : NULL;
    if (bit_obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"m[0] not found\n");
        return 0;
    }
    after(15, at_15);
    after(25, at_25);
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
