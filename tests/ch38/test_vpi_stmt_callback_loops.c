/* VPI application of test_vpi_stmt_callback_loops (IEEE 1800-2023 38.36.1.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int for_calls, delay_calls, delay_late;
static char for_data[] = "for", fork_data[] = "fork", delay_data[] = "delay";
static char event_data[] = "event";

static int now(p_cb_data data)
{
    return data->time != NULL ? (int)data->time->low : -1;
}

static PLI_INT32 on_stmt(p_cb_data data)
{
    const char *which = data->user_data ? data->user_data : "";

    if (strcmp(which, "for") == 0) {
        vpiHandle i = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_stmt_callback_loops.i", NULL);
        s_vpi_value v;
        v.format = vpiIntVal;
        v.value.integer = -1;
        if (i != NULL)
            vpi_get_value(i, &v);
        vpi_printf("for: callback %d, i=%d\n", ++for_calls, (int)v.value.integer);
    } else if (strcmp(which, "delay") == 0) {
        delay_calls++;
        if (now(data) != 0)
            delay_late++;
    } else {
        vpi_printf("%s: callback at time %d\n", which, now(data));
    }
    return 0;
}

static int place(vpiHandle stmt, char *user_data)
{
    static s_vpi_time sim_time;
    s_cb_data d;

    sim_time.type = vpiSimTime;
    memset(&d, 0, sizeof d);
    d.reason = cbStmt;
    d.cb_rtn = on_stmt;
    d.obj = stmt;
    d.time = &sim_time;
    d.user_data = user_data;
    return vpi_register_cb(&d) != NULL;
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_stmt_callback_loops", NULL);
    vpiHandle procs = top ? vpi_iterate(vpiProcess, top) : NULL;
    vpiHandle proc, block, it, stmt, branches, branch;
    int placed = 0;

    (void)data;
    while (procs != NULL && (proc = vpi_scan(procs)) != NULL) {
        block = vpi_handle(vpiStmt, proc);
        if (block == NULL || vpi_get(vpiType, block) != vpiBegin)
            continue;
        it = vpi_iterate(vpiStmt, block);
        while (it != NULL && (stmt = vpi_scan(it)) != NULL) {
            PLI_INT32 t = vpi_get(vpiType, stmt);
            if (t == vpiFor) {
                placed += place(stmt, for_data);
            } else if (t == vpiFork) {
                placed += place(stmt, fork_data);
                branches = vpi_iterate(vpiStmt, stmt);
                while (branches != NULL && (branch = vpi_scan(branches)) != NULL)
                    if (vpi_get(vpiType, branch) == vpiDelayControl)
                        placed += place(branch, delay_data);
            } else if (t == vpiEventControl) {
                placed += place(stmt, event_data);
            }
        }
    }
    vpi_printf("callbacks placed: %d\n", placed);
    return 0;
}

static PLI_INT32 on_end(p_cb_data data)
{
    (void)data;
    vpi_printf("delay controls in the fork: %d callbacks, %d of them after time 0\n",
               delay_calls, delay_late);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
    d.reason = cbEndOfSimulation;
    d.cb_rtn = on_end;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
