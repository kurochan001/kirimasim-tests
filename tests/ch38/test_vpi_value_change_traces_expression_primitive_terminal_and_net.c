/* Follow a parity expression, a primitive input terminal, and a net through VPI. */
#include <stddef.h>
#include "vpi_user.h"

#define TOP "test_vpi_value_change_traces_expression_primitive_terminal_and_net"
#define MAX_EVENTS 8

struct change_stream {
    const char *label;
    vpiHandle object;
    int same_handle, count;
    int time[MAX_EVENTS];
    char value[MAX_EVENTS];
};

static struct change_stream expression = {.label = "expression"};
static struct change_stream terminal = {.label = "input-terminal"};
static struct change_stream output_net = {.label = "output-net"};
static s_vpi_time time_request = {.type = vpiSimTime};
static s_vpi_value value_request = {.format = vpiScalarVal};

static PLI_INT32 record(p_cb_data data)
{
    struct change_stream *stream = (struct change_stream *)data->user_data;
    int index = stream->count++;
    stream->same_handle &= data->obj && vpi_compare_objects(data->obj, stream->object);
    if (index < MAX_EVENTS) {
        stream->time[index] = data->time ? (int)data->time->low : -1;
        int scalar = data->value && data->value->format == vpiScalarVal
            ? data->value->value.scalar : -1;
        stream->value[index] = scalar == vpi0 ? '0' : scalar == vpi1 ? '1' : '?';
    }
    return 0;
}

static void watch(struct change_stream *stream, vpiHandle object)
{
    stream->object = object;
    stream->same_handle = 1;
    s_cb_data callback = {
        .reason = cbValueChange,
        .cb_rtn = record,
        .obj = object,
        .time = &time_request,
        .value = &value_request,
        .user_data = (PLI_BYTE8 *)stream,
    };
    if (!object || !vpi_register_cb(&callback))
        vpi_printf("could not watch %s\n", stream->label);
}

static PLI_INT32 setup(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle top = vpi_handle_by_name(TOP, NULL);
    vpiHandle assignments = top ? vpi_iterate(vpiContAssign, top) : NULL;
    vpiHandle assignment = assignments ? vpi_scan(assignments) : NULL;
    if (assignment)
        vpi_free_object(assignments);
    watch(&expression, assignment ? vpi_handle(vpiRhs, assignment) : NULL);

    vpiHandle gate = vpi_handle_by_name(TOP ".input_gate", NULL);
    vpiHandle terminals = gate ? vpi_iterate(vpiPrimTerm, gate) : NULL;
    vpiHandle item, input = NULL;
    while (terminals && (item = vpi_scan(terminals))) {
        if (vpi_get(vpiDirection, item) == vpiInput)
            input = item;
    }
    watch(&terminal, input);
    watch(&output_net, vpi_handle_by_name(TOP ".parity", NULL));
    return 0;
}

static void print_stream(const struct change_stream *stream)
{
    vpi_printf("%s", stream->label);
    for (int i = 0; i < stream->count && i < MAX_EVENTS; ++i)
        vpi_printf(" %d:%c", stream->time[i], stream->value[i]);
    if (stream->count > MAX_EVENTS)
        vpi_printf(" additional=%d", stream->count - MAX_EVENTS);
    vpi_printf(" same-handle=%d\n", stream->same_handle);
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    print_stream(&expression);
    print_stream(&terminal);
    print_stream(&output_net);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data setup_task = {
        .type = vpiSysTask, .tfname = "$vt_watch_value_targets", .calltf = setup,
    };
    s_vpi_systf_data report_task = {
        .type = vpiSysTask, .tfname = "$vt_report_value_targets", .calltf = report,
    };
    vpi_register_systf(&setup_task);
    vpi_register_systf(&report_task);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
