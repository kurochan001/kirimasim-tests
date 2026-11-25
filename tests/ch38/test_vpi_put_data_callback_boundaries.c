#include <stddef.h>
#include <string.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static int end_save;
static PLI_INT32 stream_id;
static PLI_BYTE8 payload[] = {65, 0, 127, 32};

static int payload_size(void)
{
    return end_save ? (int)sizeof payload : 1;
}

static PLI_INT32 restore(p_cb_data callback)
{
    const PLI_INT32 *id = (const PLI_INT32 *)callback->user_data;
    const int size = payload_size();
    PLI_BYTE8 restored[sizeof payload + 1];
    memset(restored, 0x2b, sizeof restored);
    const int count = id == &stream_id ? vpi_get_data(*id, restored, size) : -1;
    vpi_printf("%s restart read=%d payload=%d guard=%d\n",
               callback->reason == cbStartOfRestart ? "start" : "end", count,
               memcmp(restored, payload, (size_t)size) == 0, restored[size] == 0x2b);
    return 0;
}

static PLI_INT32 save(p_cb_data callback)
{
    stream_id = vpi_get(vpiSaveRestartID, NULL);
    const int written = vpi_put_data(stream_id, payload, payload_size());
    const int zero = vpi_put_data(stream_id, payload, 0);
    const int negative = vpi_put_data(stream_id, payload, -1);
    vpi_printf("%s save written=%d zero=%d negative=%d\n",
               callback->reason == cbEndOfSave ? "end" : "start", written, zero, negative);
    register_action(end_save ? cbStartOfRestart : cbEndOfRestart, restore, &stream_id);
    return 0;
}

static PLI_INT32 select_writer(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle mode = iterator != NULL ? vpi_scan(iterator) : NULL;
    if (mode == NULL) {
        vpi_printf("checkpoint writer selection unavailable\n");
        return 0;
    }
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(mode, &value);
    vpi_release_handle(iterator);
    end_save = value.value.integer != 0;
    register_action(end_save ? cbEndOfSave : cbStartOfSave, save, NULL);
    return 0;
}

static void install(void)
{
    register_probe("$vt_select_checkpoint_writer", select_writer);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
