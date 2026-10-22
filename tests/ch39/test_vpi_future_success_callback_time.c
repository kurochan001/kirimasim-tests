#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int successes, event_time = -1, execution_time = -1;
static PLI_INT32 on_success(PLI_INT32 reason, p_vpi_time event, vpiHandle assertion,
                          p_vpi_attempt_info info, PLI_BYTE8 *data)
{
    s_vpi_time now;
    (void)assertion; (void)info; (void)data;
    if (reason != cbAssertionSuccess) return 0;
    now.type = vpiSimTime; vpi_get_time(NULL, &now);
    successes++; execution_time = (int)now.low;
    if (event) event_time = event->type == vpiScaledRealTime
        ? (int)(event->real + 0.5) : (int)event->low;
    return 0;
}
static PLI_INT32 watch(PLI_BYTE8 *data)
{
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_future_success_callback_time.a1", NULL);
    (void)data;
    if (!h || !vpi_register_assertion_cb(h, cbAssertionSuccess, on_success, NULL))
        vpi_printf("callback registration failed\n");
    return 0;
}
static PLI_INT32 report(PLI_BYTE8 *data)
{
    (void)data;
    vpi_printf("successes=%d event=%d execution=%d\n", successes, event_time, execution_time);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask; tf.tfname = (PLI_BYTE8 *)"$depth_success_watch"; tf.calltf = watch;
    vpi_register_systf(&tf);
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask; tf.tfname = (PLI_BYTE8 *)"$depth_success_report"; tf.calltf = report;
    vpi_register_systf(&tf);

}
void (*vlog_startup_routines[])(void) = {register_all, 0};
#ifdef __cplusplus
}
#endif
