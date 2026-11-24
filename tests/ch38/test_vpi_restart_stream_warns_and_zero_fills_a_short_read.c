#include <stddef.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 id;

static int warned(void)
{
    s_vpi_error_info info = {0};
    return vpi_chk_error(&info) == vpiWarning;
}

static PLI_INT32 read_stream(p_cb_data callback)
{
    PLI_INT32 key = *(PLI_INT32 *)callback->user_data;
    PLI_BYTE8 first = 99;
    PLI_BYTE8 short_read[] = {99, 99, 99, 99, 99};
    PLI_BYTE8 empty[] = {99, 99};
    int first_count = vpi_get_data(key, &first, 1);
    int short_count = vpi_get_data(key, short_read, sizeof short_read);
    int short_warning = warned();
    int empty_count = vpi_get_data(key, empty, sizeof empty);
    int empty_warning = warned();
    vpi_printf("read first count=%d data=%d\n", first_count, first);
    vpi_printf("short count=%d data=%d,%d,%d,%d,%d warning=%d\n",
               short_count, short_read[0], short_read[1], short_read[2], short_read[3],
               short_read[4], short_warning);
    vpi_printf("empty count=%d data=%d,%d warning=%d\n",
               empty_count, empty[0], empty[1], empty_warning);
    return 0;
}

static PLI_INT32 write_stream(p_cb_data callback)
{
    PLI_BYTE8 data[] = {10, 20, 30, 40};
    (void)callback;
    id = vpi_get(vpiSaveRestartID, NULL);
    int count = vpi_put_data(id, data, sizeof data);
    vpi_printf("save bytes=%d\n", count);
    register_action(cbStartOfRestart, read_stream, &id);
    return 0;
}

static void install(void)
{
    register_action(cbEndOfSave, write_stream, NULL);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
