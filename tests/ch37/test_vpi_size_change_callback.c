/* VPI application of test_vpi_size_change_callback (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_size_change_callback"
#define MAX 8

static char lines[MAX][96];
static int line_count;

static vpiHandle by_name(const char *path)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void record(const char *text)
{
    if (line_count < MAX) {
        snprintf(lines[line_count], sizeof lines[0], "%s", text);
        line_count++;
    }
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static PLI_INT32 size_changed(p_cb_data cb)
{
    vpiHandle obj = cb->obj;
    const char *name = vpi_get_str(vpiName, obj);
    char text[96];

    if (strcmp(name, "s") == 0) {
        s_vpi_value v;
        v.format = vpiStringVal;
        v.value.str = (PLI_BYTE8 *)"?";
        vpi_get_value(obj, &v);
        snprintf(text, sizeof text, "size %s %d, value empty %d", name,
                 cb->value != NULL ? (int)cb->value->value.integer : -1,
                 v.value.str != NULL && v.value.str[0] == '\0');
    } else {
        snprintf(text, sizeof text, "size %s %d", name,
                 cb->value != NULL ? (int)cb->value->value.integer : -1);
    }
    record(text);
    return 0;
}

static PLI_INT32 value_changed(p_cb_data cb)
{
    vpiHandle obj = cb->obj;
    const char *name = vpi_get_str(vpiName, obj);
    char text[96];

    if (cb->value != NULL && cb->value->format == vpiStringVal)
        snprintf(text, sizeof text, "value %s %s", name, cb->value->value.str);
    else
        snprintf(text, sizeof text, "value %s %d", name,
                 cb->value != NULL ? (int)cb->value->value.integer : -1);
    record(text);
    return 0;
}

static s_vpi_value cb_values[MAX];
static s_vpi_time cb_times[MAX];
static int cb_count;

static void watch(PLI_INT32 reason, const char *name, PLI_INT32 (*fn)(p_cb_data),
                  PLI_INT32 format)
{
    s_cb_data cb;
    vpiHandle obj = by_name(name);

    if (obj == NULL) {
        record("not found");
        return;
    }
    if (cb_count >= MAX)
        return;
    memset(&cb, 0, sizeof cb);
    cb.reason = reason;
    cb.cb_rtn = fn;
    cb.obj = obj;
    cb_times[cb_count].type = vpiSuppressTime;
    cb.time = &cb_times[cb_count];
    cb.value = &cb_values[cb_count];
    cb_values[cb_count].format = format;
    cb_count++;
    vpi_register_cb(&cb);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    (void)cb;
    watch(cbSizeChange, "d", size_changed, vpiIntVal);
    watch(cbSizeChange, "q", size_changed, vpiIntVal);
    watch(cbSizeChange, "aa", size_changed, vpiIntVal);
    watch(cbSizeChange, "s", size_changed, vpiIntVal);
    watch(cbValueChange, "v", value_changed, vpiIntVal);
    return 0;
}

static PLI_INT32 done_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle s = by_name("s");
    s_vpi_value v;
    int i;

    (void)user_data;
    qsort(lines, (size_t)line_count, sizeof lines[0], by_text);
    for (i = 0; i < line_count; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    v.format = vpiStringVal;
    v.value.str = (PLI_BYTE8 *)"?";
    if (s != NULL)
        vpi_get_value(s, &v);
    vpi_printf((PLI_BYTE8 *)"s after %s\n", v.value.str != NULL ? v.value.str : "NULL");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    s_cb_data cb;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_done";
    d.calltf = done_calltf;
    vpi_register_systf(&d);

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
