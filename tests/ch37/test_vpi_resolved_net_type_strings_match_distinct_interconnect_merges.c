#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_resolved_net_type_strings_match_distinct_interconnect_merges"

static void property(vpiHandle net, PLI_INT32 key, PLI_INT32 want, const char *label)
{
    PLI_INT32 got = vpi_get(key, net);
    const char *name = vpi_get_str(key, net);
    vpi_printf(" %s-int=%d %s-name=%s", label, got == want,
               label, name != NULL ? name : "<null>");
}

static void check_types(const char *label, const char *path, PLI_INT32 want)
{
    vpiHandle net = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    if (net == NULL) {
        vpi_printf("%s: net unavailable\n", label);
        return;
    }
    vpi_printf("%s:", label);
    property(net, vpiNetType, vpiInterconnect, "declared");
    property(net, vpiResolvedNetType, want, "resolved");
    vpi_printf("\n");
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    check_types("and", TOP ".and_link", vpiWand);
    check_types("or", TOP ".or_link", vpiWor);
    return 0;
}

static void register_test(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = "$vt_resolved_net_names";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_test, NULL};

#ifdef __cplusplus
}
#endif
