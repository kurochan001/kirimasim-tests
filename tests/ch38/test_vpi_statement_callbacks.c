/* VPI application of test_vpi_statement_callbacks (IEEE 1800-2023 38.36.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int while_calls, block_calls, worker_calls, worker_after;
static int removed, wrong_obj;
static vpiHandle worker_cb;

static PLI_INT32 on_stmt(p_cb_data data)
{
    const char *which = data->user_data;
    PLI_INT32 type = data->obj ? vpi_get(vpiType, data->obj) : 0;

    if (strcmp(which, "while") == 0) {
        while_calls++;
        if (type != vpiWhile)
            wrong_obj = 1;
    } else if (strcmp(which, "block") == 0) {
        block_calls++;
        if (type != vpiNamedBegin)
            wrong_obj = 1;
    } else if (removed) {
        worker_after++;
    } else {
        worker_calls++;
    }
    return 0;
}

static vpiHandle place(vpiHandle obj, const char *which)
{
    static s_vpi_time suppress;
    s_cb_data d;
    memset(&d, 0, sizeof d);
    suppress.type = vpiSuppressTime;
    d.reason = cbStmt;
    d.cb_rtn = on_stmt;
    d.obj = obj;
    d.time = &suppress;
    d.user_data = (PLI_BYTE8 *)which;
    return vpi_register_cb(&d);
}

static PLI_INT32 on_end_of_compile(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_statement_callbacks", NULL);
    vpiHandle worker = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_statement_callbacks.w", NULL);
    vpiHandle procs = top ? vpi_iterate(vpiProcess, top) : NULL;
    vpiHandle proc, block = NULL, stmts, stmt;

    (void)data;
    while (procs != NULL && (proc = vpi_scan(procs)) != NULL) {
        vpiHandle s = vpi_handle(vpiStmt, proc);
        if (s != NULL && vpi_get(vpiType, s) == vpiNamedBegin)
            block = s;
    }
    if (block == NULL) {
        vpi_printf("block body not found\n");
        return 0;
    }
    if (place(block, "block") == NULL)
        vpi_printf("callback on the block not placed\n");
    stmts = vpi_iterate(vpiStmt, block);
    while (stmts != NULL && (stmt = vpi_scan(stmts)) != NULL)
        if (vpi_get(vpiType, stmt) == vpiWhile && place(stmt, "while") == NULL)
            vpi_printf("callback on the while not placed\n");
    worker_cb = worker ? place(worker, "worker") : NULL;
    if (worker_cb == NULL)
        vpi_printf("callback on the module not placed\n");
    return 0;
}

static PLI_INT32 remove_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    if (worker_cb != NULL)
        vpi_remove_cb(worker_cb);
    removed = 1;
    return 0;
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    /* three iterations: 3, or 4 if the last test of the condition counts */
    vpi_printf("while: one callback per iteration: %s, block: %d, objects as placed: %s\n",
               while_calls == 3 || while_calls == 4 ? "yes" : "no", block_calls,
               wrong_obj ? "no" : "yes");
    vpi_printf("module: callbacks before the removal: %s, after it: %d\n",
               worker_calls > 0 ? "yes" : "none", worker_after);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data s;
    memset(&s, 0, sizeof s);
    s.type = vpiSysTask;
    s.tfname = (PLI_BYTE8 *)name;
    s.calltf = calltf;
    vpi_register_systf(&s);
}

static void register_all(void)
{
    s_cb_data d;
    add("$vt_remove", remove_calltf);
    add("$vt_report", report_calltf);
    memset(&d, 0, sizeof d);
    d.reason = cbEndOfCompile;
    d.cb_rtn = on_end_of_compile;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
