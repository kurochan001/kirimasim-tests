/* VPI application of test_vpi_stmt_callback_module_wide (IEEE 1800-2023 38.36.1.3). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_stmt_callback_module_wide"

static const PLI_INT32 types[6] = {vpiBegin, vpiAssignment, vpiIf, vpiCase, vpiDelayControl,
                                   vpiSysTaskCall};
static const char *const names[6] = {"vpiBegin", "vpiAssignment", "vpiIf", "vpiCase",
                                     "vpiDelayControl", "vpiSysTaskCall"};
static int counts[6], other_types, outside_u1;
static vpiHandle u1;

static PLI_INT32 on_stmt(p_cb_data cb)
{
    PLI_INT32 t = cb->obj ? vpi_get(vpiType, cb->obj) : 0;
    vpiHandle scope = cb->obj ? vpi_handle(vpiScope, cb->obj) : NULL;
    int k, found = 0;

    for (k = 0; k < 6; k++)
        if (t == types[k]) {
            counts[k]++;
            found = 1;
        }
    if (!found)
        other_types++;
    if (scope == NULL || !vpi_compare_objects(scope, u1))
        outside_u1++;
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time sim_time;
    s_cb_data cb;
    vpiHandle h;

    (void)data;
    u1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1", NULL);
    if (u1 == NULL) {
        vpi_printf((PLI_BYTE8 *)"u1 not found\n");
        return 0;
    }
    sim_time.type = vpiSimTime;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStmt;
    cb.cb_rtn = on_stmt;
    cb.obj = u1;
    cb.time = &sim_time;
    h = vpi_register_cb(&cb);
    vpi_printf((PLI_BYTE8 *)"callback on u1: one vpiCallback handle %s\n",
               h != NULL && vpi_get(vpiType, h) == vpiCallback ? "yes" : "no");
    return 0;
}

static PLI_INT32 on_end(p_cb_data data)
{
    int k;

    (void)data;
    for (k = 0; k < 6; k++)
        vpi_printf((PLI_BYTE8 *)"%s: %d\n", names[k], counts[k]);
    vpi_printf((PLI_BYTE8 *)"other types: %d, statements not in u1: %d\n", other_types,
               outside_u1);
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
