/* VPI application of test_vpi_stmt_callback_data (IEEE 1800-2023 38.36.1.1, 38.36.1.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static char delay_data[] = "delay";
static char assign_data[] = "assignment";
static char if_data[] = "if";
static char display_data[] = "display";

static const char *stmt_type(vpiHandle obj)
{
    PLI_INT32 t = obj ? vpi_get(vpiType, obj) : 0;
    return obj == NULL ? "NULL" : t == vpiDelayControl ? "vpiDelayControl"
           : t == vpiAssignment ? "vpiAssignment" : t == vpiIf ? "vpiIf"
           : t == vpiSysTaskCall ? "vpiSysTaskCall" : "other";
}

static int int_value(const char *name)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    snprintf(full, sizeof full, "test_vpi_stmt_callback_data.%s", name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_stmt(p_cb_data data)
{
    char when[32];
    const char *which = data->user_data ? data->user_data : "";

    if (data->time == NULL)
        snprintf(when, sizeof when, "NULL");
    else if (data->time->type == vpiSimTime)
        snprintf(when, sizeof when, "%d", (int)data->time->low);
    else
        snprintf(when, sizeof when, "of another type");
    vpi_printf("callback \"%s\": obj %s, time %s, value %s, index %d", which,
               stmt_type(data->obj), when, data->value == NULL ? "NULL" : "set",
               (int)data->index);
    if (strcmp(which, "assignment") == 0)
        vpi_printf(", x before it %d", int_value("x"));
    else if (strcmp(which, "if") == 0)
        vpi_printf(", calls before the condition %d", int_value("calls"));
    vpi_printf("\n");
    return 0;
}

static int place(vpiHandle stmt, char *user_data, PLI_INT32 time_type)
{
    static s_vpi_time kinds[2];
    s_cb_data d;
    s_vpi_time *kind = time_type == vpiSimTime ? &kinds[0] : &kinds[1];

    kind->type = time_type;
    memset(&d, 0, sizeof d);
    d.reason = cbStmt;
    d.cb_rtn = on_stmt;
    d.obj = stmt;
    d.time = kind;
    d.user_data = user_data;
    return vpi_register_cb(&d) != NULL;
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_stmt_callback_data", NULL);
    vpiHandle procs = top ? vpi_iterate(vpiProcess, top) : NULL;
    vpiHandle proc, block = NULL, it, stmt;
    int placed = 0;

    (void)data;
    while (procs != NULL && (proc = vpi_scan(procs)) != NULL)
        block = vpi_handle(vpiStmt, proc);
    it = block ? vpi_iterate(vpiStmt, block) : NULL;
    while (it != NULL && (stmt = vpi_scan(it)) != NULL) {
        PLI_INT32 t = vpi_get(vpiType, stmt);
        if (t == vpiDelayControl) {
            placed += place(stmt, delay_data, vpiSimTime);
            placed += place(vpi_handle(vpiStmt, stmt), assign_data, vpiSimTime);
        } else if (t == vpiIf) {
            placed += place(stmt, if_data, vpiSuppressTime);
        } else if (t == vpiSysTaskCall) {
            placed += place(stmt, display_data, vpiSuppressTime);
            placed += place(stmt, display_data, vpiSuppressTime);
        }
    }
    vpi_printf("callbacks placed: %d\n", placed);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
