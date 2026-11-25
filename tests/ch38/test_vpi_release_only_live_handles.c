#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_release_only_live_handles"

static vpiHandle retained;
static int releases, skips;

static int release_if_live(vpiHandle *slot)
{
    if (*slot == NULL) {
        ++skips;
        return 0;
    }

    int released = vpi_release_handle(*slot);
    *slot = NULL;
    ++releases;
    return released;
}

static PLI_INT32 start(p_cb_data unused)
{
    (void)unused;
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    retained = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bus", NULL);
    vpiHandle abandoned = top ? vpi_iterate(vpiModule, top) : NULL;
    int child_found = abandoned && vpi_scan(abandoned) != NULL;
    if (!child_found)
        abandoned = NULL;
    int released = release_if_live(&abandoned);
    release_if_live(&abandoned);

    vpiHandle exhausted = top ? vpi_iterate(vpiModule, top) : NULL;
    int children = 0;
    if (exhausted) {
        while (vpi_scan(exhausted) != NULL)
            ++children;
        exhausted = NULL;
    }
    release_if_live(&exhausted);

    vpi_printf("early child=%d release=%d drained children=%d release calls=%d skipped=%d\n",
               child_found, released, children, releases, skips);
    return 0;
}

static int observe_sharing(void)
{
    s_vpi_vlog_info info;
    if (vpi_get_vlog_info(&info)) {
        for (int i = 0; i < info.argc; ++i) {
            if (strcmp(info.argv[i], "+observe_sharing") == 0)
                return 1;
        }
    }
    return 0;
}

static PLI_INT32 finish(p_cb_data unused)
{
    (void)unused;
    vpiHandle fresh = vpi_handle_by_name((PLI_BYTE8 *)TOP ".bus", NULL);
    int net = retained && vpi_get(vpiType, retained) == vpiNet;
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    if (net)
        vpi_get_value(retained, &value);

    if (observe_sharing())
        vpi_printf("handle sharing observed=%d\n", retained && fresh && retained == fresh);
    vpi_printf("retained net=%d same object=%d value=%d\n", net,
               retained && fresh && vpi_compare_objects(retained, fresh), (int)value.value.integer);
    return 0;
}

static void install(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = start;
    vpi_register_cb(&callback);
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = finish;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
