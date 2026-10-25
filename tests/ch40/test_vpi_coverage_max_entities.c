/* VPI application of test_vpi_coverage_max_entities (IEEE 1800-2023 40.5.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_coverage_max_entities"

static int prop(vpiHandle h, int p, int empty)
{
    return h == NULL ? empty : (int)vpi_get(p, h);
}

/* The arguments are the results of the four SV_COV_CHECK calls: available is
   true where the check gave SV_COV_OK (1), and no check may have given
   SV_COV_ERROR (-1). */
static void read_arguments(int available[4], int *not_error)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = call ? vpi_iterate(vpiArgument, call) : NULL;
    int n = 0, error_seen = 0;

    available[0] = available[1] = available[2] = available[3] = 0;
    while (it != NULL && n < 4) {
        vpiHandle arg = vpi_scan(it);
        s_vpi_value v;
        if (arg == NULL)
            break;
        v.format = vpiIntVal;
        vpi_get_value(arg, &v);
        available[n] = v.value.integer == 1;
        if (v.value.integer == -1)
            error_seen = 1;
        n++;
    }
    *not_error = n > 0 && !error_seen;
}

static PLI_INT32 coverage_calltf(PLI_BYTE8 *user_data)
{
    int available[4], checks_not_error;
    vpiHandle top, sig, asrt, task, stmt, fsm = NULL, it, h;
    vpiHandle handles[4];
    int i, within_max = 1, count_at_least_covered = 1;
    int states = 0, state_max_is_one = 1, state_values = 0, statement_max, covered;

    (void)user_data;
    read_arguments(available, &checks_not_error);
    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    sig = vpi_handle_by_name((PLI_BYTE8 *)TOP ".sig", NULL);
    asrt = vpi_handle_by_name((PLI_BYTE8 *)TOP ".a_pass", NULL);
    task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".steps", NULL);
    stmt = task ? vpi_handle(vpiStmt, task) : NULL;
    it = top ? vpi_iterate(vpiFsm, top) : NULL;
    if (it != NULL) {
        fsm = vpi_scan(it);
        vpi_free_object(it);
    }

    vpi_printf("coverage checks are not ERROR: %d\n", checks_not_error);
    vpi_printf("signal: covered max %d\n", prop(sig, vpiCoveredMax, 0));
    vpi_printf("statement block: covered max %d\n", prop(stmt, vpiCoveredMax, 0));
    vpi_printf("fsm: covered max %d\n", prop(fsm, vpiCoveredMax, 0));
    it = fsm ? vpi_iterate(vpiFsmStates, fsm) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        s_vpi_value v;
        states++;
        if (prop(h, vpiCoveredMax, 0) != 1)
            state_max_is_one = 0;
        v.format = vpiIntVal;
        vpi_get_value(h, &v);
        if (v.value.integer >= 0 && v.value.integer < 3)
            state_values |= 1 << v.value.integer;
    }
    vpi_printf("fsm states: %d\n", states);
    vpi_printf("fsm state: covered max 1: %d\n", state_max_is_one);
    vpi_printf("fsm state values are 0, 1 and 2: %d\n", state_values == 7);
    vpi_printf("assertion: covered max %d\n", prop(asrt, vpiCoveredMax, 0));

    handles[0] = sig;
    handles[1] = stmt;
    handles[2] = fsm;
    handles[3] = asrt;
    for (i = 0; i < 4; i++) {
        if (handles[i] == NULL)
            continue;
        if (prop(handles[i], vpiCovered, 0) > prop(handles[i], vpiCoveredMax, 0))
            within_max = 0;
        if (prop(handles[i], vpiCoveredCount, 0) < prop(handles[i], vpiCovered, 0))
            count_at_least_covered = 0;
    }
    vpi_printf("covered is within the maximum: %d\n", within_max);
    vpi_printf("covered count is at least covered: %d\n", count_at_least_covered);

    /* Each entity of each of these handles is covered exactly once. */
    statement_max = prop(stmt, vpiCoveredMax, 0);
    covered = prop(stmt, vpiCovered, 0);
    vpi_printf("statement: the three statements are covered: %d\n",
               !available[1] || covered == 3);
    vpi_printf("statement: covered count is the statement count: %d\n",
               !available[1] || (prop(stmt, vpiCoveredCount, 0) == statement_max
                                 && statement_max == 3));
    vpi_printf("signal: the eight bits are covered: %d\n",
               !available[0] || prop(sig, vpiCovered, 0) == 8);
    vpi_printf("signal: covered count is the bit count: %d\n",
               !available[0] || prop(sig, vpiCoveredCount, 0) == 8);
    vpi_printf("fsm: the three states are covered: %d\n",
               !available[3] || prop(fsm, vpiCovered, 0) == 3);
    vpi_printf("assertion: covered is one: %d\n",
               !available[2] || prop(asrt, vpiCovered, 0) == 1);
    vpi_printf("instance toggle coverage includes the signal: %d\n",
               !available[0] || prop(top, vpiToggleCoverage, 0)
                                    >= prop(sig, vpiCovered, 0));
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
