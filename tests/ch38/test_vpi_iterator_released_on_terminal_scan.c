#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int trace_enabled(void)
{
    s_vpi_vlog_info info;
    int i;
    if (!vpi_get_vlog_info(&info))
        return 0;
    for (i = 0; i < info.argc; i++)
        if (strcmp(info.argv[i], "+trace_iterators") == 0)
            return 1;
    return 0;
}

static void trace(int active, const char *phase, vpiHandle iterator)
{
    if (active) {
        if (iterator != NULL)
            printf("ITER_TEST %s %p\n", phase, (void *)iterator);
        else
            printf("ITER_TEST %s\n", phase);
        fflush(stdout);
    }
}

static int module_bit(vpiHandle child)
{
    const char *name = child ? vpi_get_str(vpiName, child) : NULL;
    if (name == NULL)
        return 0;
    if (strcmp(name, "first") == 0)
        return 1;
    if (strcmp(name, "second") == 0)
        return 2;
    if (strcmp(name, "third") == 0)
        return 4;
    return 0;
}

static PLI_INT32 check_iterators(p_cb_data data)
{
    const int observe = trace_enabled();
    vpiHandle top, early, drained, first, child;
    int i, released, seen = 0, terminal;
    (void)data;

    top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_iterator_released_on_terminal_scan", NULL);
    if (top == NULL)
        return 0;
    early = vpi_iterate(vpiModule, top);
    drained = vpi_iterate(vpiModule, top);
    if (early == NULL || drained == NULL)
        return 0;
    trace(observe, "early_open", early);
    trace(observe, "drained_open", drained);

    first = vpi_scan(early);
    if (first == NULL)
        return 0;
    trace(observe, "explicit_release", early);
    released = vpi_release_handle(early);
    trace(observe, "explicit_done", NULL);
    vpi_printf("early release=%d child readable=%d\n", released, module_bit(first) != 0);

    for (i = 0; i < 3; i++) {
        child = vpi_scan(drained);
        if (child == NULL)
            return 0;
        seen |= module_bit(child);
    }
    trace(observe, "terminal_scan", drained);
    terminal = vpi_scan(drained) == NULL;
    trace(observe, "terminal_done", NULL);
    vpi_printf("drained modules=%d terminal null=%d\n", seen, terminal);
    return 0;
}

static void register_callback(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = check_iterators;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_callback, NULL};

#ifdef __cplusplus
}
#endif
