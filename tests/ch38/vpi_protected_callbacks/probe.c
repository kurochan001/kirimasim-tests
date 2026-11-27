#include <stdio.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define WORKER "test_vpi_protected_statement_callbacks.worker"

enum statement_slot {
    outer, left_block, left_delay, left_write, right_block, right_delay, right_write,
    tail_delay, tail_write, slot_count
};

static const char *const names[slot_count] = {
    "outer", "left-block", "left-delay", "left-write", "right-block", "right-delay",
    "right-write", "tail-delay", "tail-write"
};
static vpiHandle statements[slot_count];
static int module_events[slot_count], direct_events[slot_count], unknown_events;
static vpiHandle module_registration;

/* The backing Ghost bridge delivers the same handle used to register each
   statement. Distinct named blocks can compare equal with vpi_compare_objects. */
static PLI_INT32 on_statement(p_cb_data data)
{
    int *counts = data->user_data != NULL ? direct_events : module_events;
    for (unsigned slot = 0; slot < slot_count; ++slot) {
        if (data->obj == statements[slot] && data->obj != NULL) {
            ++counts[slot];
            return 0;
        }
    }
    ++unknown_events;
    return 0;
}

static vpiHandle register_statement(vpiHandle object, int direct)
{
    static s_vpi_time time = {0};
    s_cb_data data = {0};
    time.type = vpiSuppressTime;
    data.reason = cbStmt;
    data.cb_rtn = on_statement;
    data.obj = object;
    data.time = &time;
    data.user_data = direct ? (PLI_BYTE8 *)"direct" : NULL;
    return vpi_register_cb(&data);
}

static int capture(vpiHandle iterator, enum statement_slot slot, PLI_INT32 type)
{
    if (iterator == NULL)
        return 0;
    vpiHandle object = vpi_scan(iterator);
    if (object == NULL || vpi_get(vpiType, object) != type)
        return 0;
    statements[slot] = object;
    return 1;
}

static int capture_branch(vpiHandle children, enum statement_slot block, enum statement_slot delay,
                          enum statement_slot write)
{
    if (!capture(children, block, vpiNamedBegin))
        return 0;
    vpiHandle body = vpi_iterate(vpiStmt, statements[block]);
    return capture(body, delay, vpiDelayControl) && capture(body, write, vpiAssignment) && vpi_scan(body) == NULL;
}

static int capture_tree(vpiHandle worker)
{
    if (worker == NULL)
        return 0;
    vpiHandle processes = vpi_iterate(vpiProcess, worker);
    if (processes == NULL)
        return 0;
    vpiHandle initial = vpi_scan(processes);
    if (initial == NULL || vpi_scan(processes) != NULL)
        return 0;
    statements[outer] = vpi_handle(vpiStmt, initial);
    if (statements[outer] == NULL || vpi_get(vpiType, statements[outer]) != vpiNamedBegin)
        return 0;
    vpiHandle children = vpi_iterate(vpiStmt, statements[outer]);
    return capture_branch(children, left_block, left_delay, left_write) &&
           capture_branch(children, right_block, right_delay, right_write) &&
           capture(children, tail_delay, vpiDelayControl) && capture(children, tail_write, vpiAssignment) &&
           vpi_scan(children) == NULL;
}

#ifdef REFERENCE_CALLBACKS
#include "envelope_range.h"

static vpiHandle member_callbacks[slot_count];

static int protected_statement(enum statement_slot slot)
{
    /* The statement handles of delays and assignments have no source line in
       Ghost. Use the named block that owns the statement in this fixture. */
    enum statement_slot origin = outer;
    if (slot >= left_block && slot <= left_write)
        origin = left_block;
    else if (slot >= right_block && slot <= right_write)
        origin = right_block;
    PLI_INT32 line = vpi_get(vpiLineNo, statements[origin]);
    return envelope_begin < line && line < envelope_end;
}

static vpiHandle register_direct(enum statement_slot slot)
{
    if (protected_statement(slot)) {
        fprintf(stderr, "vpi_register_cb: cbStmt on protected statement (%s)\n", names[slot]);
        return NULL;
    }
    return register_statement(statements[slot], 1);
}

static vpiHandle register_module(vpiHandle worker)
{
    (void)worker;
    for (unsigned slot = 0; slot < slot_count; ++slot) {
        if (!protected_statement((enum statement_slot)slot))
            member_callbacks[slot] = register_statement(statements[slot], 0);
        vpi_printf("module placement %s=%d\n", names[slot], member_callbacks[slot] != NULL);
    }
    /* The outer callback is clear and serves as this fixture's group handle. */
    return member_callbacks[outer];
}

static PLI_INT32 remove_module(vpiHandle registration)
{
    if (registration == NULL || registration != member_callbacks[outer])
        return 0;
    PLI_INT32 okay = 1;
    for (unsigned slot = 0; slot < slot_count; ++slot) {
        if (member_callbacks[slot] != NULL && !vpi_remove_cb(member_callbacks[slot]))
            okay = 0;
        member_callbacks[slot] = NULL;
    }
    return okay;
}
#else
static vpiHandle register_direct(enum statement_slot slot)
{
    return register_statement(statements[slot], 1);
}

static vpiHandle register_module(vpiHandle worker)
{
    return register_statement(worker, 0);
}

static PLI_INT32 remove_module(vpiHandle registration)
{
    return registration != NULL && vpi_remove_cb(registration);
}
#endif

static PLI_INT32 on_remove(p_cb_data unused)
{
    (void)unused;
    vpi_printf("module removed=%d\n", (int)remove_module(module_registration));
    return 0;
}

static PLI_INT32 on_compile_end(p_cb_data unused)
{
    (void)unused;
    vpiHandle worker = vpi_handle_by_name((PLI_BYTE8 *)WORKER, NULL);
    if (!capture_tree(worker)) {
        vpi_printf("statement tree incomplete\n");
        return 0;
    }
    vpi_printf("block lines outer=%d left=%d right=%d\n", (int)vpi_get(vpiLineNo, statements[outer]),
               (int)vpi_get(vpiLineNo, statements[left_block]), (int)vpi_get(vpiLineNo, statements[right_block]));
    module_registration = register_module(worker);
    vpi_printf("module registered=%d\n", module_registration != NULL);
    const enum statement_slot direct_slots[] = {left_block, right_block, tail_write};
    for (unsigned attempt = 0; attempt < sizeof direct_slots / sizeof direct_slots[0]; ++attempt) {
        const enum statement_slot slot = direct_slots[attempt];
        vpi_printf("direct registration %s=%d\n", names[slot], register_direct(slot) != NULL);
    }
    static s_vpi_time time = {0};
    s_cb_data data = {0};
    time.type = vpiSimTime;
    time.low = 2500;
    data.reason = cbAfterDelay;
    data.cb_rtn = on_remove;
    data.time = &time;
    vpi_printf("removal scheduled=%d\n", vpi_register_cb(&data) != NULL);
    return 0;
}

static int read_integer(const char *path)
{
    vpiHandle object = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    if (object == NULL)
        return -1;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(object, &value);
    return (int)value.value.integer;
}

static PLI_INT32 on_end(p_cb_data unused)
{
    (void)unused;
    for (unsigned slot = 0; slot < slot_count; ++slot)
        vpi_printf("events %s module=%d direct=%d\n", names[slot], module_events[slot], direct_events[slot]);
    vpi_printf("events unknown=%d\n", unknown_events);
    int left = read_integer(WORKER ".left_value");
    int right = read_integer(WORKER ".right_value");
    int tail = read_integer(WORKER ".tail_value");
    vpi_printf("values left=%d right=%d tail=%d\n", left, right, tail);
    return 0;
}

static void install(void)
{
    s_cb_data data = {0};
    data.reason = cbEndOfCompile;
    data.cb_rtn = on_compile_end;
    vpi_register_cb(&data);
    data.reason = cbEndOfSimulation;
    data.cb_rtn = on_end;
    vpi_register_cb(&data);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
