#include <stddef.h>
#include "vpi_user.h"

#define TOP "test_vpi_callback_relationship_arrows"

enum { TERMINAL, EXPRESSION, STATEMENT, QUEUE, END_SIM, ERROR_EVENT, WATCH_COUNT };

struct watch {
    const char *name;
    PLI_INT32 reason;
    vpiHandle reference, object, callback;
    int calls;
};

static struct watch watches[WATCH_COUNT] = {
    [TERMINAL] = {.name = "terminal", .reason = cbValueChange},
    [EXPRESSION] = {.name = "expression", .reason = cbValueChange},
    [STATEMENT] = {.name = "statement", .reason = cbStmt},
    [QUEUE] = {.name = "time queue", .reason = cbAfterDelay},
    [END_SIM] = {.name = "end of simulation", .reason = cbEndOfSimulation},
    [ERROR_EVENT] = {.name = "error", .reason = cbError},
};
static s_vpi_time suppressed_time = {.type = vpiSuppressTime};
static s_vpi_time delay = {.type = vpiSimTime, .low = 5};
static s_vpi_value suppressed_value = {.format = vpiSuppressVal};
static unsigned timer_time;

static int same_object(vpiHandle first, vpiHandle second)
{
    return first && second && vpi_compare_objects(first, second);
}

static PLI_INT32 record(p_cb_data data)
{
    struct watch *watch = (struct watch *)data->user_data;
    ++watch->calls;
    if (watch == &watches[QUEUE] && data->time && data->time->high == 0)
        timer_time = data->time->low;
    return 0;
}

static void subscribe(struct watch *watch)
{
    s_cb_data data = {
        .reason = watch->reason, .cb_rtn = record, .obj = watch->object,
        .time = watch == &watches[QUEUE] ? &delay : &suppressed_time,
        .value = &suppressed_value, .user_data = (PLI_BYTE8 *)watch,
    };
    watch->callback = vpi_register_cb(&data);
}

static vpiHandle input_terminal(void)
{
    vpiHandle gate = vpi_handle_by_name(TOP ".input_gate", NULL);
    vpiHandle iter = gate ? vpi_iterate(vpiPrimTerm, gate) : NULL;
    vpiHandle member, input = NULL;
    while (iter && (member = vpi_scan(iter))) {
        if (vpi_get(vpiType, member) == vpiPrimTerm && vpi_get(vpiDirection, member) == vpiInput)
            input = member;
    }
    return input;
}

static vpiHandle rhs_expression(vpiHandle top)
{
    vpiHandle iter = top ? vpi_iterate(vpiContAssign, top) : NULL;
    vpiHandle member, expression = NULL;
    while (iter && (member = vpi_scan(iter))) {
        vpiHandle rhs = vpi_handle(vpiRhs, member);
        if (rhs && vpi_get(vpiType, rhs) == vpiOperation && vpi_get(vpiOpType, rhs) == vpiUnaryXorOp)
            expression = rhs;
    }
    return expression;
}

static vpiHandle while_statement(vpiHandle top)
{
    vpiHandle processes = top ? vpi_iterate(vpiProcess, top) : NULL;
    vpiHandle process, statement = NULL;
    while (processes && (process = vpi_scan(processes))) {
        vpiHandle body = vpi_handle(vpiStmt, process);
        if (body && vpi_get(vpiType, body) == vpiNamedBegin) {
            vpiHandle statements = vpi_iterate(vpiStmt, body);
            vpiHandle member;
            while (statements && (member = vpi_scan(statements))) {
                if (vpi_get(vpiType, member) == vpiWhile)
                    statement = member;
            }
        }
    }
    return statement;
}

static vpiHandle scheduled_queue(void)
{
    vpiHandle iter = vpi_iterate(vpiTimeQueue, NULL), member, queue = NULL;
    while (iter && (member = vpi_scan(iter))) {
        s_vpi_time time = {.type = vpiSimTime};
        vpi_get_time(member, &time);
        if (vpi_get(vpiType, member) == vpiTimeQueue && time.high == 0 && time.low == 6)
            queue = member;
    }
    return queue;
}

static int correct_info(vpiHandle callback, const struct watch *watch)
{
    if (!callback || vpi_get(vpiType, callback) != vpiCallback)
        return 0;
    s_cb_data info = {0};
    vpi_get_cb_info(callback, &info);
    return info.reason == watch->reason && info.cb_rtn == record
        && info.user_data == (const PLI_BYTE8 *)watch
        && (watch->object ? same_object(info.obj, watch->object) : info.obj == NULL);
}

static void check_link(const struct watch *watch)
{
    vpiHandle linked = watch->reference ? vpi_handle(vpiCallback, watch->reference) : NULL;
    vpi_printf("%s reference=%d registered=%d registration-info=%d linked=%d linked-info=%d\n",
               watch->name, watch->reference != NULL, watch->callback != NULL,
               correct_info(watch->callback, watch), same_object(linked, watch->callback),
               correct_info(linked, watch));
}

static void scan_unrelated(void)
{
    vpiHandle iter = vpi_iterate(vpiCallback, NULL), member;
    int found[WATCH_COUNT] = {0}, unknown = 0;
    while (iter && (member = vpi_scan(iter))) {
        int index;
        for (index = TERMINAL; index < WATCH_COUNT; ++index) {
            if (same_object(member, watches[index].callback) && correct_info(member, &watches[index])) {
                ++found[index];
                break;
            }
        }
        unknown += index == WATCH_COUNT;
    }
    vpi_printf("unrelated end=%d error=%d terminal=%d expression=%d statement=%d queue=%d unknown=%d\n",
               found[END_SIM], found[ERROR_EVENT], found[TERMINAL], found[EXPRESSION],
               found[STATEMENT], found[QUEUE], unknown);
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle empty = vpi_iterate(vpiCallback, NULL);
    vpi_printf("empty iterator is null=%d\n", empty == NULL);
    if (empty)
        while (vpi_scan(empty)) { }

    vpiHandle top = vpi_handle_by_name(TOP, NULL);
    watches[TERMINAL].reference = input_terminal();
    watches[EXPRESSION].reference = rhs_expression(top);
    watches[STATEMENT].reference = while_statement(top);
    for (int index = TERMINAL; index <= STATEMENT; ++index) {
        struct watch *watch = &watches[index];
        watch->object = watch->reference;
        if (watch->object)
            subscribe(watch);
    }
    subscribe(&watches[QUEUE]);
    watches[QUEUE].reference = scheduled_queue();
    subscribe(&watches[END_SIM]);
    subscribe(&watches[ERROR_EVENT]);
    for (int index = TERMINAL; index <= QUEUE; ++index)
        check_link(&watches[index]);
    scan_unrelated();
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("fired statement=%d timer=%d time=%u\n",
               watches[STATEMENT].calls > 0, watches[QUEUE].calls, timer_time);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data observe = {
        .type = vpiSysTask, .tfname = "$inspect_callback_arrows", .calltf = inspect,
    };
    s_vpi_systf_data finish = {
        .type = vpiSysTask, .tfname = "$report_callback_arrows", .calltf = report,
    };
    vpi_register_systf(&observe);
    vpi_register_systf(&finish);
}

void (*vlog_startup_routines[])(void) = {install, NULL};
