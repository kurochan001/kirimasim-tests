/* VPI application of test_vpi_time_callback_scaled_real (IEEE 1800-2023 38.36.2). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_time_callback_scaled_real"

static PLI_INT32 on_time(p_cb_data cb)
{
    s_vpi_time now;

    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    vpi_printf("%s: called at %d\n", cb->user_data, (int)now.low);
    return 0;
}

static void request(PLI_INT32 reason, const char *scope, double real, const char *what)
{
    static s_vpi_time times[3];
    static int used = 0;
    s_vpi_time *t = &times[used++];
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    t->type = vpiScaledRealTime;
    t->high = 0;
    t->low = 0;
    t->real = real;
    cb.reason = reason;
    cb.cb_rtn = on_time;
    cb.obj = vpi_handle_by_name((PLI_BYTE8 *)scope, NULL);
    cb.time = t;
    cb.user_data = (PLI_BYTE8 *)what;
    if (cb.obj == NULL)
        vpi_printf("%s: no object\n", what);
    else if (vpi_register_cb(&cb) == NULL)
        vpi_printf("%s: not registered\n", what);
}

static PLI_INT32 on_start(p_cb_data cb)
{
    (void)cb;
    request(cbAfterDelay, TOP ".u_sub", 3.0, "cbAfterDelay 3.0 in u_sub (10 ns)");
    request(cbAfterDelay, TOP, 3.0, "cbAfterDelay 3.0 in the top module (1 ns)");
    request(cbAtStartOfSimTime, TOP ".u_sub", 2.0, "cbAtStartOfSimTime 2.0 in u_sub (10 ns)");
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
