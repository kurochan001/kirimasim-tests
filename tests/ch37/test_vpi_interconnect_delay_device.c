/* VPI observations for the single-load and fanout SDF fixtures. */
#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#if defined(vpiDelayDevice) && defined(vpiDelayTerm) && defined(vpiDelayType) && \
    defined(vpiInTerm) && defined(vpiOutTerm)
static vpiHandle find_argument(vpiHandle *arguments)
{
    vpiHandle argument = *arguments == NULL ? NULL : vpi_scan(*arguments);
    if (argument == NULL) {
        *arguments = NULL;
        return NULL;
    }
    s_vpi_value value = {0};
    value.format = vpiStringVal;
    vpi_get_value(argument, &value);
    return value.value.str == NULL ? NULL : vpi_handle_by_name(value.value.str, NULL);
}

static vpiHandle related(PLI_INT32 relation, vpiHandle object)
{
    return object == NULL ? NULL : vpi_handle(relation, object);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b);
}

static vpiHandle delay_term(PLI_INT32 relation, vpiHandle net)
{
    vpiHandle iterator = net == NULL ? NULL : vpi_iterate(relation, net);
    vpiHandle result = NULL;
    vpiHandle item;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        if (result == NULL && vpi_get(vpiType, item) == vpiDelayTerm)
            result = item;
    }
    return result;
}

static int driver_or_load(PLI_INT32 relation, vpiHandle terminal)
{
    vpiHandle iterator = terminal == NULL ? NULL : vpi_iterate(relation, terminal);
    vpiHandle item;
    int member_found = 0;
    int all_members_valid = 1;
    while (iterator != NULL && (item = vpi_scan(iterator)) != NULL) {
        switch (vpi_get(vpiType, item)) {
        case vpiPort:
        case vpiPortBit:
        case vpiPrimTerm:
        case vpiAssignStmt:
        case vpiContAssign:
        case vpiContAssignBit:
        case vpiDelayTerm:
        case vpiForce:
            member_found = 1;
            break;
        default:
            all_members_valid = 0;
            break;
        }
    }
    return member_found && all_members_valid;
}

static PLI_INT32 delay_type(vpiHandle object)
{
    return object == NULL ? -1 : vpi_get(vpiDelayType, object);
}

static char scalar(vpiHandle object)
{
    if (object == NULL)
        return '-';
    s_vpi_value value = {0};
    value.format = vpiScalarVal;
    value.value.scalar = vpiX;
    vpi_get_value(object, &value);
    switch (value.value.scalar) {
    case vpi0: return '0';
    case vpi1: return '1';
    case vpiZ: return 'z';
    default: return 'x';
    }
}

static PLI_INT32 snapshot(PLI_BYTE8 *unused)
{
    static int first = 1;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle arguments = call == NULL ? NULL : vpi_iterate(vpiArgument, call);
    vpiHandle source = find_argument(&arguments);
    vpiHandle target = find_argument(&arguments);
    vpiHandle owner = find_argument(&arguments);
    vpiHandle direct = find_argument(&arguments);
    (void)unused;
    if (arguments != NULL)
        vpi_release_handle(arguments);

    vpiHandle source_load = delay_term(vpiLoad, source);
    vpiHandle target_driver = delay_term(vpiDriver, target);
    vpiHandle device = related(vpiDelayDevice, source_load);
    if (device == NULL)
        device = related(vpiDelayDevice, target_driver);
    vpiHandle input = related(vpiInTerm, device);
    vpiHandle output = related(vpiOutTerm, device);

    if (first) {
        first = 0;
        vpiHandle module = related(vpiModule, device);
        int device_type = device != NULL && vpi_get(vpiType, device) == vpiDelayDevice;
        int input_type = input != NULL && vpi_get(vpiType, input) == vpiDelayTerm;
        int output_type = output != NULL && vpi_get(vpiType, output) == vpiDelayTerm;
        vpi_printf("delay objects source=%d target=%d owner=%d\n",
                   source != NULL, target != NULL, owner != NULL);
        vpi_printf("delay graph device=%d module=%d input=%d output=%d distinct=%d\n",
                   device_type, same(module, owner), input_type, output_type,
                   input != NULL && output != NULL && !same(input, output));
        vpi_printf("delay term origins input=%d output=%d\n",
                   same(related(vpiDelayDevice, input), device),
                   same(related(vpiDelayDevice, output), device));
        vpi_printf("delay net relations source-load=%d target-driver=%d input-driver=%d output-load=%d\n",
                   same(source_load, input), same(target_driver, output),
                   driver_or_load(vpiDriver, input), driver_or_load(vpiLoad, output));
        vpi_printf("delay subtypes device=%d input=%d output=%d\n",
                   (int)delay_type(device), (int)delay_type(input), (int)delay_type(output));
        if (direct != NULL)
            vpi_printf("delay control branch has-device=%d\n", delay_term(vpiDriver, direct) != NULL);
    }
    vpi_printf("delay term values input=%c output=%c\n", scalar(input), scalar(output));
    return 0;
}
#else
static PLI_INT32 snapshot(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("delay device or terminal declarations unavailable\n");
    return 0;
}
#endif

static void install(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_delay_snapshot";
    task.calltf = snapshot;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};

#ifdef __cplusplus
}
#endif
