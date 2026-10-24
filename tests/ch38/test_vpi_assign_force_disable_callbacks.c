/* VPI application of test_vpi_assign_force_disable_callbacks (IEEE 1800-2023 38.36.1). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assign_force_disable_callbacks"

static const char *type_name(vpiHandle h)
{
    PLI_INT32 t = h ? vpi_get(vpiType, h) : 0;
    return h == NULL ? "NULL" : t == vpiAssignStmt ? "vpiAssignStmt"
           : t == vpiDeassign ? "vpiDeassign" : t == vpiForce ? "vpiForce"
           : t == vpiRelease ? "vpiRelease" : t == vpiEventStmt ? "vpiEventStmt"
           : t == vpiDisable ? "vpiDisable" : "another";
}

static int value_of(const char *name)
{
    char full[96];
    vpiHandle h;
    s_vpi_value v;

    strcpy(full, TOP ".");
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static PLI_INT32 on_stmt(p_cb_data cb)
{
    PLI_INT32 t = cb->obj ? vpi_get(vpiType, cb->obj) : 0;

    vpi_printf((PLI_BYTE8 *)"%d: cbStmt %s", (int)cb->time->low, type_name(cb->obj));
    if (t == vpiAssignStmt || t == vpiDeassign)
        vpi_printf((PLI_BYTE8 *)", q=%d", value_of("q"));
    else if (t == vpiForce || t == vpiRelease)
        vpi_printf((PLI_BYTE8 *)", w=%d", value_of("w"));
    vpi_printf((PLI_BYTE8 *)"\n");
    return 0;
}

static PLI_INT32 on_disable(p_cb_data cb)
{
    PLI_INT32 t = cb->obj ? vpi_get(vpiType, cb->obj) : 0;

    vpi_printf((PLI_BYTE8 *)"%d: %s: obj the named fork or its system task call: %s\n",
               (int)cb->time->low, cb->user_data,
               t == vpiNamedFork || t == vpiSysTaskCall ? "yes" : "no");
    return 0;
}

static PLI_INT32 on_other(p_cb_data cb)
{
    vpi_printf((PLI_BYTE8 *)"%d: %s: obj %s", (int)cb->time->low, cb->user_data,
               type_name(cb->obj));
    if (cb->value == NULL)
        vpi_printf((PLI_BYTE8 *)", value NULL\n");
    else if (cb->value->format == vpiIntVal)
        vpi_printf((PLI_BYTE8 *)", value %d\n", (int)cb->value->value.integer);
    else
        vpi_printf((PLI_BYTE8 *)", value of another format\n");
    return 0;
}

static void watch(PLI_INT32 reason, vpiHandle obj, PLI_INT32 (*rtn)(p_cb_data), const char *what)
{
    static s_vpi_time sim_time;
    static s_vpi_value values[13];
    static int used = 0;
    s_cb_data cb;

    sim_time.type = vpiSimTime;
    values[used].format = vpiIntVal;
    memset(&cb, 0, sizeof cb);
    cb.reason = reason;
    cb.cb_rtn = rtn;
    cb.obj = obj;
    cb.time = &sim_time;
    cb.value = &values[used++];
    cb.user_data = (PLI_BYTE8 *)what;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not registered\n", what);
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle procs = top ? vpi_iterate(vpiProcess, top) : NULL;
    vpiHandle proc, block = NULL, it, stmt;

    (void)data;
    while (procs != NULL && (proc = vpi_scan(procs)) != NULL)
        if (vpi_get(vpiType, proc) == vpiInitial)
            block = vpi_handle(vpiStmt, proc);
    it = block ? vpi_iterate(vpiStmt, block) : NULL;
    while (it != NULL && (stmt = vpi_scan(it)) != NULL) {
        PLI_INT32 t = vpi_get(vpiType, stmt);
        if (t == vpiAssignStmt || t == vpiDeassign || t == vpiForce || t == vpiRelease
            || t == vpiEventStmt || t == vpiDisable)
            watch(cbStmt, stmt, on_stmt, "cbStmt");
        if (t == vpiEventStmt)
            watch(cbValueChange, stmt, on_other, "cbValueChange on the event statement");
    }
    watch(cbAssign, vpi_handle_by_name((PLI_BYTE8 *)TOP ".q", NULL), on_other, "cbAssign");
    watch(cbDeassign, vpi_handle_by_name((PLI_BYTE8 *)TOP ".q", NULL), on_other, "cbDeassign");
    watch(cbForce, NULL, on_other, "cbForce");
    watch(cbRelease, NULL, on_other, "cbRelease");
    watch(cbDisable, vpi_handle_by_name((PLI_BYTE8 *)TOP ".worker", NULL), on_disable,
          "cbDisable");
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
