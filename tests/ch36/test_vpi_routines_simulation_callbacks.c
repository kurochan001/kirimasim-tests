/* VPI application of test_vpi_routines_simulation_callbacks (IEEE 1800-2023 36.11, Table 36-1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    int count;
    char text[128];
} seen_list;

static seen_list keep_seen, drop_seen;
static vpiHandle drop_cb;
static int removed = -1;
static PLI_UINT32 removed_at;
static PLI_BYTE8 keep_data[] = "keep";
static PLI_BYTE8 drop_data[] = "drop";

static void record(seen_list *list, p_cb_data data)
{
    size_t used = strlen(list->text);
    snprintf(list->text + used, sizeof list->text - used, " %d@%u",
             (int)data->value->value.integer, (unsigned)data->time->low);
    list->count++;
}

static PLI_INT32 on_keep(p_cb_data data)
{
    record(&keep_seen, data);
    return 0;
}

static PLI_INT32 on_drop(p_cb_data data)
{
    record(&drop_seen, data);
    return 0;
}

static PLI_INT32 on_delay(p_cb_data data)
{
    s_vpi_time now;
    (void)data;
    now.type = vpiSimTime;
    vpi_get_time(NULL, &now);
    removed_at = now.low;
    removed = vpi_remove_cb(drop_cb);
    return 0;
}

static PLI_INT32 on_end(p_cb_data data)
{
    (void)data;
    vpi_printf("time callback at %u: vpi_remove_cb of drop returned %d\n",
               (unsigned)removed_at, removed);
    vpi_printf("keep saw:%s\n", keep_seen.text);
    vpi_printf("drop saw:%s\n", drop_seen.text);
    return 0;
}

static vpiHandle place(PLI_INT32 reason, vpiHandle obj, PLI_INT32 (*routine)(p_cb_data),
                       PLI_UINT32 delay, PLI_BYTE8 *user_data)
{
    static s_vpi_time time_kind;
    static s_vpi_value value_kind;
    s_cb_data d;

    time_kind.type = vpiSimTime;
    time_kind.high = 0;
    time_kind.low = delay;
    value_kind.format = vpiIntVal;
    memset(&d, 0, sizeof d);
    d.reason = reason;
    d.cb_rtn = routine;
    d.obj = obj;
    d.user_data = user_data;
    if (reason != cbEndOfSimulation) {
        d.time = &time_kind;
        d.value = &value_kind;
    }
    return vpi_register_cb(&d);
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle r = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_routines_simulation_callbacks.r", NULL);
    s_cb_data info;
    const char *obj_name;

    (void)data;
    if (r == NULL) {
        vpi_printf("r not found\n");
        return 0;
    }
    place(cbValueChange, r, on_keep, 0, keep_data);
    drop_cb = place(cbValueChange, r, on_drop, 0, drop_data);
    place(cbAfterDelay, NULL, on_delay, 15, NULL);
    place(cbEndOfSimulation, NULL, on_end, 0, NULL);

    memset(&info, 0, sizeof info);
    if (drop_cb != NULL)
        vpi_get_cb_info(drop_cb, &info);
    obj_name = info.obj != NULL ? vpi_get_str(vpiFullName, info.obj) : NULL;
    vpi_printf("vpi_get_cb_info of drop: reason cbValueChange %d, routine on_drop %d, "
               "object %s, user data %s\n", info.reason == cbValueChange,
               info.cb_rtn == on_drop, obj_name ? obj_name : "(none)",
               info.user_data ? (const char *)info.user_data : "(none)");
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
