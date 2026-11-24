#include <stddef.h>
#include <string.h>
#include "checkpoint_fixtures/action_callback.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 ids[2];

static int has_location(void)
{
    PLI_BYTE8 *location = vpi_get_str(vpiSaveRestartLocation, NULL);
    return location != NULL && location[0] != '\0';
}

static PLI_INT32 read_streams(p_cb_data callback)
{
    PLI_INT32 *keys = (PLI_INT32 *)callback->user_data;
    PLI_BYTE8 left[5] = {0};
    PLI_BYTE8 right[5] = {0};
    const PLI_BYTE8 expected_left[] = {18, 64, 7, 0, 92};
    const PLI_BYTE8 expected_right[] = {31, 5, 47, 88, 11};
    int path = has_location();
    int left_first = vpi_get_data(keys[0], left, 3);
    int right_first = vpi_get_data(keys[1], right, 4);
    int left_last = vpi_get_data(keys[0], left + 3, 2);
    int right_last = vpi_get_data(keys[1], right + 4, 1);
    vpi_printf("restart path=%d counts=%d,%d,%d,%d left=%d right=%d\n",
               path, left_first, right_first, left_last, right_last,
               memcmp(left, expected_left, sizeof left) == 0,
               memcmp(right, expected_right, sizeof right) == 0);
    return 0;
}

static PLI_INT32 write_streams(p_cb_data callback)
{
    PLI_BYTE8 left_head[] = {18, 64};
    PLI_BYTE8 right_head[] = {31, 5, 47};
    PLI_BYTE8 left_tail[] = {7, 0, 92};
    PLI_BYTE8 right_tail[] = {88, 11};
    (void)callback;
    int path = has_location();
    ids[0] = vpi_get(vpiSaveRestartID, NULL);
    ids[1] = vpi_get(vpiSaveRestartID, NULL);
    int left_first = vpi_put_data(ids[0], left_head, sizeof left_head);
    int right_first = vpi_put_data(ids[1], right_head, sizeof right_head);
    int left_last = vpi_put_data(ids[0], left_tail, sizeof left_tail);
    int right_last = vpi_put_data(ids[1], right_tail, sizeof right_tail);
    vpi_printf("save distinct ids=%d path=%d writes=%d,%d,%d,%d\n",
               ids[0] != ids[1], path, left_first, right_first, left_last, right_last);
    register_action(cbEndOfRestart, read_streams, ids);
    return 0;
}

static void install(void)
{
    register_action(cbStartOfSave, write_streams, NULL);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
