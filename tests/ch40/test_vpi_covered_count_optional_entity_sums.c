/* IEEE 1800-2023 40.2.2 and 40.5.2: sum available optional hit counts. */
#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_covered_count_optional_entity_sums"

static int get_count(vpiHandle object)
{
    return object ? vpi_get(vpiCoveredCount, object) : vpiUndefined;
}

static int get_value(const char *name)
{
    vpiHandle object = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    if (!object)
        return -2;
    vpi_get_value(object, &value);
    return value.value.integer;
}

static void check_statements(int verbose)
{
    vpiHandle task = vpi_handle_by_name((PLI_BYTE8 *)TOP ".steps", NULL);
    vpiHandle block = task ? vpi_handle(vpiStmt, task) : NULL;
    vpiHandle iter = block ? vpi_iterate(vpiStmt, block) : NULL;
    vpiHandle statement;
    int total = get_count(block), children[2] = {vpiUndefined, vpiUndefined};
    int statements = 0;

    while (iter && (statement = vpi_scan(iter))) {
        if (statements < 2)
            children[statements] = get_count(statement);
        statements++;
    }
    int available = total != vpiUndefined || children[0] != vpiUndefined || children[1] != vpiUndefined;
    int valid = !available || (children[0] == 2 && children[1] == 2 && total == children[0] + children[1]);
    vpi_printf("statements: block=%d children=%d count_rule=%d\n", block != NULL, statements, valid);
    if (verbose)
        vpi_printf("statement raw: started=%d total=%d children=%d,%d\n",
                   get_value(TOP ".statement_started"), total, children[0], children[1]);
}

static void check_signal(int verbose)
{
    vpiHandle signal = vpi_handle_by_name((PLI_BYTE8 *)TOP ".signal_bits", NULL);
    int total = get_count(signal), counts[3], handles = 0;
    int available = total != vpiUndefined;

    for (int index = 0; index < 3; index++) {
        vpiHandle bit_handle = signal ? vpi_handle_by_index(signal, index) : NULL;
        handles += bit_handle != NULL;
        counts[index] = get_count(bit_handle);
        available |= counts[index] != vpiUndefined;
    }
    int valid = !available || (counts[0] > 0 && counts[1] > 0 && counts[2] == 0 &&
                                total == (PLI_INT64)counts[0] + counts[1]);
    vpi_printf("signal: vector=%d bits=%d count_rule=%d\n", signal != NULL, handles, valid);
    if (verbose)
        vpi_printf("signal raw: started=%d total=%d bits=%d,%d,%d\n",
                   get_value(TOP ".toggle_started"), total, counts[0], counts[1], counts[2]);
}

static PLI_INT32 observe(p_cb_data callback)
{
    (void)callback;
    int verbose = get_value(TOP ".verbose") == 1;
    check_statements(verbose);
    check_signal(verbose);
    return 0;
}

static PLI_INT32 schedule(p_cb_data ignored)
{
    static s_vpi_time time = {vpiSimTime, 0, 5, 0.0};
    s_cb_data callback = {0};
    (void)ignored;
    callback.reason = cbReadOnlySynch;
    callback.time = &time;
    callback.cb_rtn = observe;
    vpi_register_cb(&callback);
    return 0;
}

static void register_all(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = schedule;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_all, NULL};

#ifdef __cplusplus
}
#endif
