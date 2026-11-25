#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(vpiContAssignBit) && defined(vpiOffset)
static int drives_destination(vpiHandle assignment)
{
    if (assignment == NULL || vpi_get(vpiType, assignment) != vpiContAssign)
        return 0;
    vpiHandle lhs = vpi_handle(vpiLhs, assignment);
    const char *name = lhs != NULL ? vpi_get_str(vpiName, lhs) : NULL;
    return name != NULL && strcmp(name, "destination") == 0;
}

static int count_destination_loads(vpiHandle net, int offset, int *bit_loads)
{
    vpiHandle iterator = net != NULL ? vpi_iterate(vpiLoad, net) : NULL;
    vpiHandle load;
    int count = 0;
    while (iterator != NULL && (load = vpi_scan(iterator)) != NULL) {
        if (vpi_get(vpiType, load) == vpiContAssignBit) {
            if (!drives_destination(vpi_handle(vpiParent, load)))
                continue;
            if (bit_loads != NULL)
                ++(*bit_loads);
            if (offset < 0 || (vpi_get(vpiOffset, load) == offset && vpi_get(vpiSize, load) == 1))
                ++count;
        } else if (offset < 0 && drives_destination(load)) {
            ++count;
        }
    }
    return count;
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call != NULL ? vpi_handle(vpiScope, call) : NULL;
    vpiHandle args = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle direction = args != NULL ? vpi_scan(args) : NULL;
    if (scope == NULL || direction == NULL) {
        if (direction != NULL)
            vpi_release_handle(args);
        vpi_printf("bit load probe arguments unavailable\n");
        return 0;
    }
    s_vpi_value value = {0};
    value.format = vpiIntVal;
    vpi_get_value(direction, &value);
    vpi_release_handle(args);

    vpiHandle net = vpi_handle_by_name((PLI_BYTE8 *)"source", scope);
    vpi_printf("whole net reaches destination=%d\n", count_destination_loads(net, -1, NULL) > 0);
    for (int index = 0; index < 4; ++index) {
        const int offset = value.value.integer ? 3 - index : index;
        vpiHandle bit = net != NULL ? vpi_handle_by_index(net, index) : NULL;
        int bit_loads = 0;
        const int matching = count_destination_loads(bit, offset, &bit_loads);
        vpi_printf("source bit=%d destination offset=%d bit loads=%d matching=%d\n",
                   index, offset, bit_loads, matching);
    }
    return 0;
}
#else
static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("continuous assignment bit declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_cont_assignment_bit_loads";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
