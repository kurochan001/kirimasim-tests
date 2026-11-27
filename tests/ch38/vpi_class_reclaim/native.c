#include <stddef.h>
#include "client.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_class_reclaim_lifetimes"

static int creates, type_deliveries, instance_deliveries;
static PLI_INT64 first_id;
static int distinct_ids;

static PLI_INT32 on_reclaim(p_cb_data data)
{
    reclaim_observation event = observe_callback(data, vpi_get, vpi_get64);
    if (data->user_data == NULL)
        ++type_deliveries;
    else
        ++instance_deliveries;
    vpi_printf("native reclaim reason=%d time-null=%d class=%d id-live=%d\n",
               event.reason == cbReclaimObj, event.no_time, event.typed, event.id > 0);
    return 0;
}

static PLI_INT32 on_create(p_cb_data data)
{
    reclaim_observation event = observe_callback(data, vpi_get, vpi_get64);
    ++creates;
    vpi_printf("native creation class=%d id-live=%d\n", event.typed, event.id > 0);
    if (creates == 1) {
        first_id = event.id;
        static s_vpi_time requested = {0};
        requested.type = vpiSimTime;
        s_cb_data request = {0};
        request.reason = cbReclaimObj;
        request.cb_rtn = on_reclaim;
        request.obj = data->obj;
        request.time = &requested;
        request.user_data = (PLI_BYTE8 *)"instance";
        vpi_printf("native reclaim object accepted=%d\n", vpi_register_cb(&request) != NULL);
    } else if (creates == 2) {
        distinct_ids = first_id > 0 && event.id > 0 && event.id != first_id;
    }
    return 0;
}

static PLI_INT32 setup(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle var = vpi_handle_by_name((PLI_BYTE8 *)TOP ".first", NULL);
    vpiHandle typespec = var == NULL ? NULL : vpi_handle(vpiClassTypespec, var);
    if (typespec == NULL) {
        vpi_printf("native class typespec missing\n");
        return 0;
    }
    s_cb_data request = {0};
    request.reason = cbCreateObj;
    request.cb_rtn = on_create;
    request.obj = typespec;
    vpi_printf("native create typespec accepted=%d\n", vpi_register_cb(&request) != NULL);
    request.reason = cbReclaimObj;
    request.cb_rtn = on_reclaim;
    vpi_printf("native reclaim typespec accepted=%d\n", vpi_register_cb(&request) != NULL);
    request.obj = var;
    vpi_printf("native reclaim variable accepted=%d\n", vpi_register_cb(&request) != NULL);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("native counts create=%d distinct=%d type=%d object=%d\n",
               creates, distinct_ids, type_deliveries, instance_deliveries);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_reclaim_setup";
    task.calltf = setup;
    vpi_register_systf(&task);
    task.tfname = (PLI_BYTE8 *)"$vt_reclaim_report";
    task.calltf = report;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
