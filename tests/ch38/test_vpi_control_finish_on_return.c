/* VPI application of test_vpi_control_finish_on_return (IEEE 1800-2023 38.4). */
#include <string.h>
#include "vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    PLI_INT32 undefined, finish;

    (void)cb;
    undefined = vpi_control(12345);
    finish = vpi_control(vpiFinish, 0);
    vpi_printf((PLI_BYTE8 *)"%d: undefined operation returned %d\n", now(), (int)undefined);
    vpi_printf((PLI_BYTE8 *)"%d: vpiFinish returned %d, the routine goes on\n", now(),
               (int)finish);
    return 0;
}

static PLI_INT32 on_end(p_cb_data cb)
{
    (void)cb;
    vpi_printf((PLI_BYTE8 *)"%d: end of simulation\n", now());
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time delay;
    s_cb_data cb;

    (void)data;
    vpi_printf((PLI_BYTE8 *)"vpi_control PLI_INT32 (*)(PLI_INT32, ...) %d\n",
               SAME_TYPE(&vpi_control, PLI_INT32 (*)(PLI_INT32, ...)));
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 5;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &delay;
    vpi_register_cb(&cb);
    memset(&cb, 0, sizeof cb);
    cb.reason = cbEndOfSimulation;
    cb.cb_rtn = on_end;
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
