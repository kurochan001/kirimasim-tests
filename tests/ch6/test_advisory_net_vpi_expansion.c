#include <stddef.h>
#include "vpi_user.h"

#ifndef vpiExpanded
/* Some implementations omit the property from their VPI header. */
#define vpiExpanded 25
#endif

#ifdef __cplusplus
extern "C" {
#endif

static void observe_vector(vpiHandle net, const char *name, const PLI_INT32 values[],
                           int require_expansion)
{
    int correct_bits = 0;
    int matching_flags = 0;

    if (net == NULL || vpi_get(vpiType, net) != vpiNet) {
        vpi_printf("%s not found as vpiNet\n", name);
        return;
    }
    PLI_INT32 expanded = vpi_get(vpiExpanded, net);
    for (int index = 4; index <= 6; ++index) {
        vpiHandle bit = vpi_handle_by_index(net, index);
        if (bit != NULL && vpi_get(vpiType, bit) == vpiNetBit) {
            s_vpi_value value = {0};
            value.format = vpiScalarVal;
            vpi_get_value(bit, &value);
            correct_bits += value.value.scalar == values[index - 4];
            matching_flags += vpi_get(vpiExpanded, bit) == expanded;
        }
    }

    // §6.9.2 requires expansion when the scalared advisory is implemented.
    // Both expansion modes are permitted for vectored. The bits must be
    // available in either mode under §37.16 and report their parent's flag.
    int valid_expansion = expanded == 1 || (!require_expansion && expanded == 0);
    vpi_printf("%s allowed expansion=%d correct bits=%d matching flags=%d\n",
               name, valid_expansion, correct_bits, matching_flags);
    if (!valid_expansion)
        vpi_printf("%s vpiExpanded=%d\n", name, (int)expanded);
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = vpi_handle(vpiScope, call);
    const PLI_INT32 scalar_bits[] = {vpi1, vpi1, vpi0};
    const PLI_INT32 vector_bits[] = {vpi1, vpi0, vpi0};

    vpiHandle scalar_bus = vpi_handle_by_name((PLI_BYTE8 *)"scalar_bus", scope);
    if (scalar_bus != NULL)
        observe_vector(scalar_bus, "scalar_bus", scalar_bits, 1);
    else
        observe_vector(vpi_handle_by_name((PLI_BYTE8 *)"vector_bus", scope),
                       "vector_bus", vector_bits, 0);
    return 0;
}

static void register_observation(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_net_expansion";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
