/* VPI application of test_vpi_callback_memory_index (IEEE 1800-2023 38.8, 38.36.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static s_cb_data registered;
static int new_structure = 0, user_data_ok = 0, wrong = 0;
static char copied[32];

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static PLI_INT32 on_change(p_cb_data cb)
{
    const char *value = cb->value != NULL && cb->value->value.str != NULL
                        ? cb->value->value.str : "(none)";

    if (cb != &registered)
        new_structure = 1;
    if (cb->user_data != NULL && strcmp((const char *)cb->user_data, "mem") == 0)
        user_data_ok = 1;
    if (cb->obj == NULL || vpi_get_str(vpiName, cb->obj) == NULL
            || strcmp(vpi_get_str(vpiName, cb->obj), "mem") != 0)
        wrong = 1;
    if (cb->time == NULL || cb->time->type != vpiSimTime || (int)cb->time->low != now())
        wrong = 1;
    snprintf(copied, sizeof copied, "%s", value);
    vpi_printf("%d: index %d, value %s, user data %s\n", now(), (int)cb->index, value,
               cb->user_data != NULL ? (const char *)cb->user_data : "(NULL)");
    return 0;
}

static PLI_INT32 watch_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_callback_memory_index.mem",
                                       NULL);
    static s_vpi_time when;
    static s_vpi_value value;

    (void)user_data;
    if (mem == NULL) {
        vpi_printf("mem not found\n");
        return 0;
    }
    memset(&registered, 0, sizeof registered);
    when.type = vpiSimTime;
    value.format = vpiHexStrVal;
    registered.reason = cbValueChange;
    registered.cb_rtn = on_change;
    registered.obj = mem;
    registered.time = &when;
    registered.value = &value;
    registered.user_data = (PLI_BYTE8 *)"mem";
    vpi_register_cb(&registered);
    return 0;
}

static PLI_INT32 done_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf("new structure %d, user data kept %d, object and time as registered %d\n",
               new_structure, user_data_ok, wrong ? 0 : 1);
    vpi_printf("copied value %s\n", copied);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_watch", watch_calltf);
    add("$vt_done", done_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
