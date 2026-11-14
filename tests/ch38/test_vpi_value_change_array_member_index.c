/* VPI application of test_vpi_value_change_array_member_index (IEEE 1800-2023 38.36.1). */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_value_change_array_member_index."
#define MAX_INDICES 4

static s_cb_data request;
static s_vpi_time request_time;
static s_vpi_value request_value;

static PLI_INT32 on_change(p_cb_data cb)
{
    PLI_INT32 indices[MAX_INDICES];
    int count = 0, k, j;
    vpiHandle it, x;

    if (cb->time == NULL || cb->value == NULL || cb->obj == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no time, value or object\n", cb->user_data);
        return 0;
    }
    it = vpi_iterate(vpiIndex, cb->obj);
    while (it != NULL && (x = vpi_scan(it)) != NULL) {
        s_vpi_value v;
        v.format = vpiIntVal;
        vpi_get_value(x, &v);
        if (count < MAX_INDICES)
            indices[count] = v.value.integer;
        count++;
    }
    for (k = 1; k < count && k < MAX_INDICES; k++)
        for (j = k; j > 0 && indices[j - 1] > indices[j]; j--) {
            PLI_INT32 t = indices[j];
            indices[j] = indices[j - 1];
            indices[j - 1] = t;
        }
    vpi_printf((PLI_BYTE8 *)"%d: %s value %d, index %d, vpiArrayMember %d, indices",
               (int)cb->time->low, cb->user_data,
               cb->value->format == vpiIntVal ? (int)cb->value->value.integer : -1,
               (int)cb->index, (int)vpi_get(vpiArrayMember, cb->obj));
    for (k = 0; k < count && k < MAX_INDICES; k++)
        vpi_printf((PLI_BYTE8 *)" %d", (int)indices[k]);
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static void watch(vpiHandle member, const char *label)
{
    if (member == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", label);
        return;
    }
    memset(&request, 0, sizeof request);
    request.reason = cbValueChange;
    request.cb_rtn = on_change;
    request.obj = member;
    request.time = &request_time;
    request.value = &request_value;
    request.user_data = (PLI_BYTE8 *)label;
    if (vpi_register_cb(&request) == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not registered\n", label);
}

static PLI_INT32 at_1(p_cb_data data)
{
    vpiHandle m = vpi_handle_by_name((PLI_BYTE8 *)TOP "m", NULL);
    vpiHandle w = vpi_handle_by_name((PLI_BYTE8 *)TOP "w", NULL);
    PLI_INT32 first[2] = {1, 6}, second[2] = {2, 4};

    (void)data;
    request_time.type = vpiSimTime;
    request_value.format = vpiIntVal;
    if (m == NULL || w == NULL) {
        vpi_printf((PLI_BYTE8 *)"arrays not found\n");
        return 0;
    }
    watch(vpi_handle_by_multi_index(m, 2, first), "m[1][6]");
    watch(vpi_handle_by_multi_index(m, 2, second), "m[2][4]");
    watch(vpi_handle_by_index(w, 2), "w[2]");
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data cb;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_1;
    cb.time = &one;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
