#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int started;

static PLI_INT32 start(p_cb_data data)
{
    (void)data;
    started = 1;
    return 0;
}

#if defined(vpiDelayType) && defined(vpiInterModPathDelay) && defined(vpiDelayDevice) && \
    defined(vpiDelayTerm) && defined(vpiInTerm) && defined(vpiOutTerm)
#define TOP "test_vpi_sdf_delay_device_and_terminal_type_names"

static vpiHandle find_terminal(const char *name, PLI_INT32 relation)
{
    vpiHandle net = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    vpiHandle iterator = net != NULL ? vpi_iterate(relation, net) : NULL;
    vpiHandle candidate;
    while (iterator != NULL && (candidate = vpi_scan(iterator)) != NULL) {
        if (vpi_get(vpiType, candidate) == vpiDelayTerm) {
            vpi_release_handle(iterator);
            return candidate;
        }
    }
    return NULL;
}

static vpiHandle parent_device(vpiHandle terminal)
{
    return terminal != NULL ? vpi_handle(vpiDelayDevice, terminal) : NULL;
}

static void report(const char *role, vpiHandle object, PLI_INT32 type)
{
    const int present = object != NULL && vpi_get(vpiType, object) == type;
    const int matches = present && vpi_get(vpiDelayType, object) == vpiInterModPathDelay;
    const char *name = present ? vpi_get_str(vpiDelayType, object) : NULL;
    vpi_printf("delay %s object=%d integer=%d name=%d\n", role, present, matches,
               name != NULL && strcmp(name, "vpiInterModPathDelay") == 0);
}

static void inspect_delay(void)
{
    vpiHandle device = parent_device(find_terminal(TOP ".branch", vpiLoad));
    if (device == NULL)
        device = parent_device(find_terminal(TOP ".sink.d", vpiDriver));
    report("device", device, vpiDelayDevice);
    report("input", device != NULL ? vpi_handle(vpiInTerm, device) : NULL, vpiDelayTerm);
    report("output", device != NULL ? vpi_handle(vpiOutTerm, device) : NULL, vpiDelayTerm);
}
#else
static void inspect_delay(void)
{
    vpi_printf("delay subtype declarations unavailable\n");
}
#endif

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
#if defined(vpiDelayType) && defined(vpiType) && defined(vpiLoad) && defined(cbStartOfSimulation)
    vpi_printf("delay subtype API macro names=1\n");
#else
    vpi_printf("delay subtype API macro names=0\n");
#endif
    vpi_printf("delay subtype start callback=%d\n", started);
    inspect_delay();
    return 0;
}

static void install(void)
{
    s_cb_data cb = {0};
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start;
    vpi_register_cb(&cb);
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_delay_type_names";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
