/* VPI application of test_vpi_coverage_partial_entities (IEEE 1800-2023 40.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_coverage_partial_entities"

static int prop(vpiHandle h, int p)
{
    return h == NULL ? 0 : (int)vpi_get(p, h);
}

static vpiHandle first_of(vpiHandle parent, int type)
{
    vpiHandle it = parent ? vpi_iterate(type, parent) : NULL;
    vpiHandle h = it ? vpi_scan(it) : NULL;
    if (h != NULL)
        vpi_free_object(it);
    return h;
}

/* $vt_cov(toggle_check, statement_check, fsm_check, toggle_u): the first three
   are the results of SV_COV_CHECK for toggle coverage of u and for statement
   and FSM state coverage of the top module, and toggle_u is $coverage_get of
   the toggle coverage of u. A value is checked only where its check gave
   SV_COV_OK (1); no check may have given SV_COV_ERROR (-1). */
static PLI_INT32 coverage_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    int args[4] = {-1, -1, -1, 0};
    int n = 0, toggle, statement, fsm_ok, error_seen;
    vpiHandle u, sig, steps, idle, steps_block, idle_block, fsm, h;
    int states = 0, states_as_reached = 1;

    (void)user_data;
    while (it != NULL && n < 4) {
        vpiHandle arg = vpi_scan(it);
        s_vpi_value v;
        if (arg == NULL) {
            it = NULL;
            break;
        }
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        args[n++] = v.value.integer;
    }
    if (it != NULL)
        vpi_free_object(it);
    error_seen = n < 4 || args[0] == -1 || args[1] == -1 || args[2] == -1;
    toggle = args[0] == 1;
    statement = args[1] == 1;
    fsm_ok = args[2] == 1;

    u = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    sig = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u.sig", NULL);
    steps = vpi_handle_by_name((PLI_BYTE8 *)TOP ".steps", NULL);
    idle = vpi_handle_by_name((PLI_BYTE8 *)TOP ".idle", NULL);
    steps_block = steps ? vpi_handle(vpiStmt, steps) : NULL;
    idle_block = idle ? vpi_handle(vpiStmt, idle) : NULL;
    fsm = first_of(vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), vpiFsm);

    vpi_printf("coverage checks are not ERROR: %d\n", !error_seen);
    vpi_printf("signal: covered max %d\n", prop(sig, vpiCoveredMax));
    vpi_printf("signal: only the 3 bits that were 0 and 1 are covered: %d\n",
               !toggle || prop(sig, vpiCovered) == 3);
    vpi_printf("instance u: vpiToggleCoverage counts its 3 covered bits, as $coverage_get does: %d\n",
               !toggle || (prop(u, vpiToggleCoverage) == 3 && args[3] == 3));
    vpi_printf("block run twice: covered max %d\n", prop(steps_block, vpiCoveredMax));
    vpi_printf("block run twice: 3 statements covered: %d\n",
               !statement || prop(steps_block, vpiCovered) == 3);
    vpi_printf("block never run: covered max %d\n", prop(idle_block, vpiCoveredMax));
    vpi_printf("block never run: no statement covered: %d\n",
               !statement || prop(idle_block, vpiCovered) == 0);
    vpi_printf("fsm: covered max %d\n", prop(fsm, vpiCoveredMax));
    vpi_printf("fsm: 2 of the 3 states are covered: %d\n",
               !fsm_ok || prop(fsm, vpiCovered) == 2);
    it = fsm ? vpi_iterate(vpiFsmStates, fsm) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        s_vpi_value v;
        int want;
        states++;
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        want = v.value.integer == 2 ? 0 : 1;
        if (fsm_ok && (prop(h, vpiCovered) != 0) != want)
            states_as_reached = 0;
    }
    vpi_printf("fsm states: %d\n", states);
    vpi_printf("fsm: states 0 and 1 are covered and state 2 is not: %d\n", states_as_reached);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cov";
    d.calltf = coverage_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
