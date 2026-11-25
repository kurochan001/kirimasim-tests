#include <string.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 stream_id;

static PLI_INT32 load_at_start(p_cb_data callback)
{
    const PLI_INT32 *id = (const PLI_INT32 *)callback->user_data;
    const PLI_BYTE8 expected[] = {52, 0, 17, 79};
    PLI_BYTE8 restored[sizeof expected] = {0};
    int count = id == &stream_id ? vpi_get_data(*id, restored, sizeof restored) : 0;
    vpi_printf("start restart: id=%d read=%d bytes=%d\n",
               id == &stream_id, count, memcmp(restored, expected, sizeof restored) == 0);
    return 0;
}

static PLI_INT32 store_at_end(p_cb_data callback)
{
    PLI_BYTE8 data[] = {52, 0, 17, 79};
    (void)callback;
    stream_id = vpi_get(vpiSaveRestartID, NULL);
    int count = vpi_put_data(stream_id, data, sizeof data);
    vpi_printf("end save: written=%d\n", count);
    register_action(cbStartOfRestart, load_at_start, &stream_id);
    return 0;
}

static void install(void)
{
    register_action(cbEndOfSave, store_at_end, NULL);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
