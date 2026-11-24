#include <stddef.h>
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_size_callbacks_precede_value_callbacks_and_report_new_size"

struct trace {
    const char *label;
    char events[160];
};

static struct trace dynamic_values = {"dynamic", ""};
static struct trace queue = {"queue", ""};
static struct trace associative = {"associative", ""};
static struct trace text = {"string", ""};
static struct trace fixed = {"fixed", ""};
static unsigned registrations;
static s_vpi_time cb_times[7];
static s_vpi_value cb_values[7];
static unsigned next_callback;

static PLI_INT32 collect(p_cb_data cb)
{
    struct trace *trace = (struct trace *)cb->user_data;
    size_t used = strlen(trace->events);
    char *out = trace->events + used;
    size_t room = sizeof trace->events - used;
    const s_vpi_value *value = cb->value;

    if (value == NULL) {
        snprintf(out, room, " no-value");
    } else if (cb->reason == cbSizeChange && value->format == vpiIntVal) {
        int incoming = value->value.integer;
        if (trace == &text) {
            s_vpi_value old_value = {0};
            old_value.format = vpiStringVal;
            vpi_get_value(cb->obj, &old_value);
            snprintf(out, room, " S%d:\"%s\"", incoming,
                     old_value.value.str == NULL ? "(missing)" : old_value.value.str);
        } else {
            snprintf(out, room, " S%d/%d", incoming, (int)vpi_get(vpiSize, cb->obj));
        }
    } else if (cb->reason == cbValueChange && trace == &text &&
               value->format == vpiStringVal && value->value.str != NULL) {
        snprintf(out, room, " V:\"%s\"", value->value.str);
    } else if (cb->reason == cbValueChange && value->format == vpiIntVal) {
        snprintf(out, room, " V%d", (int)value->value.integer);
    } else {
        snprintf(out, room, " wrong-format");
    }
    return 0;
}

static unsigned watch(const char *name, PLI_INT32 reason, PLI_INT32 format,
                      struct trace *trace)
{
    vpiHandle object = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (object == NULL)
        return 0;

    unsigned index = next_callback++;
    cb_times[index].type = vpiSuppressTime;
    cb_values[index].format = format;
    s_cb_data cb = {0};
    cb.reason = reason;
    cb.cb_rtn = collect;
    cb.obj = object;
    cb.time = &cb_times[index];
    cb.value = &cb_values[index];
    cb.user_data = (PLI_BYTE8 *)trace;
    return vpi_register_cb(&cb) != NULL;
}

static PLI_INT32 watch_call(PLI_BYTE8 *unused)
{
    (void)unused;
    /* Register value before size to distinguish API ordering from insertion order. */
    registrations += watch(TOP ".text", cbValueChange, vpiStringVal, &text);
    registrations += watch(TOP ".text", cbSizeChange, vpiIntVal, &text);
    registrations += watch(TOP ".dynamic_values", cbSizeChange, vpiIntVal, &dynamic_values);
    registrations += watch(TOP ".queued", cbSizeChange, vpiIntVal, &queue);
    registrations += watch(TOP ".indexed", cbSizeChange, vpiIntVal, &associative);
    registrations += watch(TOP ".fixed_value", cbValueChange, vpiIntVal, &fixed);
    watch(TOP ".fixed_value", cbSizeChange, vpiIntVal, &fixed);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    const struct trace *traces[] = {&dynamic_values, &queue, &associative, &text, &fixed};

    vpi_printf("registrations=%u\n", registrations);
    for (size_t i = 0; i < sizeof traces / sizeof *traces; ++i)
        vpi_printf("%s:%s\n", traces[i]->label, traces[i]->events);
    return 0;
}

static void add_task(const char *name, PLI_INT32 (*callback)(PLI_BYTE8 *))
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = (PLI_BYTE8 *)name;
    definition.calltf = callback;
    vpi_register_systf(&definition);
}

static void setup(void)
{
    add_task("$vt_watch_resize", watch_call);
    add_task("$vt_report_resize", report);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
