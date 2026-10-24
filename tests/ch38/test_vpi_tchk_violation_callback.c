/* VPI application of test_vpi_tchk_violation_callback (IEEE 1800-2023 38.36.3). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int violations;

static int now(void)
{
    s_vpi_time t;
    t.type = vpiSimTime;
    vpi_get_time(NULL, &t);
    return (int)t.low;
}

static const char *kind(vpiHandle obj)
{
    if (obj == NULL || vpi_get(vpiType, obj) != vpiTchk)
        return "no timing check";
    switch (vpi_get(vpiTchkType, obj)) {
    case vpiSetup:
        return "$setup";
    case vpiHold:
        return "$hold";
    default:
        return "another timing check";
    }
}

static PLI_INT32 on_violation(p_cb_data cb)
{
    violations++;
    vpi_printf((PLI_BYTE8 *)"%d: reason cbTchkViolation %d, obj is the %s check\n", now(),
               cb->reason == cbTchkViolation, kind(cb->obj));
    return 0;
}

static PLI_INT32 count_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"%d: cbTchkViolation callbacks: %d\n", now(), violations);
    return 0;
}

/* A startup routine may place only the reasons of 36.10.2, so cbTchkViolation is
   placed at the start of the simulation, before any timing check is evaluated. */
static PLI_INT32 start_of_simulation(p_cb_data start)
{
    s_cb_data cb;

    (void)start;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbTchkViolation;
    cb.cb_rtn = on_violation;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf((PLI_BYTE8 *)"cbTchkViolation not registered\n");
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    s_vpi_systf_data d;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_count";
    d.calltf = count_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
