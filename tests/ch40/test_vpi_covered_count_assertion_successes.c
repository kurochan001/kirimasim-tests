/* IEEE 1800-2023 40.5.2: compare generic and assertion-specific counts. */
#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_covered_count_assertion_successes"

static void report(const char *label, const char *path)
{
    vpiHandle assertion = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    int attempts = assertion ? vpi_get(vpiAssertAttemptCovered, assertion) : vpiUndefined;
    int successes = assertion ? vpi_get(vpiAssertSuccessCovered, assertion) : vpiUndefined;
    int covered_count = assertion ? vpi_get(vpiCoveredCount, assertion) : vpiUndefined;

    vpi_printf("%s: assertion=%d attempts=%d successes=%d covered_count=%d\n",
               label, assertion && vpi_get(vpiType, assertion) == vpiAssert,
               attempts, successes, covered_count);
}

static PLI_INT32 observe(p_cb_data callback)
{
    (void)callback;
    report("all", TOP ".all_edges");
    report("selected", TOP ".selected_edges");
    return 0;
}

static PLI_INT32 schedule(p_cb_data ignored)
{
    static s_vpi_time time = {vpiSimTime, 0, 6, 0.0};
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
