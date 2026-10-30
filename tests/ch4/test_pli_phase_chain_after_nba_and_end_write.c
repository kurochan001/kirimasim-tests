#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_pli_phase_chain_after_nba_and_end_write."
static int read_write_calls;
static vpiHandle named(const char *name)
{
    char full[160]; snprintf(full, sizeof full, "%s%s", TOP, name);
    return vpi_handle_by_name(full, NULL);
}
static int read_int(const char *name)
{
    s_vpi_value v; vpiHandle h = named(name);
    if (!h) return -1000;
    v.format = vpiIntVal; vpi_get_value(h, &v); return v.value.integer;
}
static void write_int(const char *name, int value)
{
    s_vpi_value v; vpiHandle h = named(name);
    if (!h) { vpi_printf("missing %s\n", name); return; }
    v.format = vpiIntVal; v.value.integer = value;
    vpi_put_value(h, &v, NULL, vpiNoDelay);
}
static PLI_INT32 pre_active(p_cb_data cb)
{ (void)cb; write_int("value", 10); return 0; }
static PLI_INT32 read_write(p_cb_data cb)
{ (void)cb; read_write_calls++; return 0; }
static PLI_INT32 end_time(p_cb_data cb)
{ (void)cb; write_int("value", 30); return 0; }
static PLI_INT32 read_only(p_cb_data cb)
{
    (void)cb;
    vpi_printf("captured=%d read_write_calls=%d\n", read_int("captured"), read_write_calls);
    vpi_printf("read_only=%d,%d\n", read_int("value"), read_int("reacted"));
    return 0;
}
static void place(PLI_INT32 reason, PLI_INT32 (*routine)(p_cb_data))
{
    s_cb_data cb; s_vpi_time time;
    memset(&cb, 0, sizeof cb); memset(&time, 0, sizeof time);
    time.type = vpiSimTime; time.low = 5;
    cb.reason = reason; cb.cb_rtn = routine; cb.time = &time;
    if (!vpi_register_cb(&cb)) vpi_printf("registration failed %d\n", reason);
}
static PLI_INT32 install(PLI_BYTE8 *data)
{
    (void)data;
    place(cbAfterDelay, pre_active); place(cbReadWriteSynch, read_write);
    place(cbAtEndOfSimTime, end_time); place(cbReadOnlySynch, read_only);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask; tf.tfname = (PLI_BYTE8 *)"$depth_install"; tf.calltf = install;
    vpi_register_systf(&tf);

}
void (*vlog_startup_routines[])(void) = {register_all, 0};
#ifdef __cplusplus
}
#endif
