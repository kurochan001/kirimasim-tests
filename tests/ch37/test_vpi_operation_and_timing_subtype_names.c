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

static int subtype_name(vpiHandle object, PLI_INT32 property, const char *expected)
{
    const char *name = object != NULL ? vpi_get_str(property, object) : NULL;
    return name != NULL && strcmp(name, expected) == 0;
}

static void operation(vpiHandle arg, PLI_INT32 expected, const char *name)
{
    const int present = arg != NULL && vpi_get(vpiType, arg) == vpiOperation;
    vpi_printf("%s operation=%d integer=%d name=%d\n", name, present,
               present && vpi_get(vpiOpType, arg) == expected,
               present && subtype_name(arg, vpiOpType, name));
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
#if defined(vpiOperation) && defined(vpiOpType) && defined(vpiTchkType) && defined(cbStartOfSimulation)
    vpi_printf("subtype API macro names=1\n");
#else
    vpi_printf("subtype API macro names=0\n");
#endif
    vpi_printf("subtype start callback=%d\n", started);
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    vpiHandle add = args != NULL ? vpi_scan(args) : NULL;
    vpiHandle bit_and = add != NULL ? vpi_scan(args) : NULL;
    operation(add, vpiAddOp, "vpiAddOp");
    operation(bit_and, vpiBitAndOp, "vpiBitAndOp");
    if (bit_and != NULL)
        vpi_release_handle(args);

    const char *path = "test_vpi_operation_and_timing_subtype_names.timing";
    vpiHandle module = vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
    vpiHandle checks = module != NULL ? vpi_iterate(vpiTchk, module) : NULL;
    vpiHandle item;
    int count = 0, setup = 0, hold = 0, setup_named = 0, hold_named = 0;
    while (checks != NULL && (item = vpi_scan(checks)) != NULL) {
        ++count;
        switch (vpi_get(vpiTchkType, item)) {
        case vpiSetup:
            ++setup;
            setup_named += subtype_name(item, vpiTchkType, "vpiSetup");
            break;
        case vpiHold:
            ++hold;
            hold_named += subtype_name(item, vpiTchkType, "vpiHold");
            break;
        default:
            break;
        }
    }
    vpi_printf("timing check count=%d\n", count);
    vpi_printf("vpiSetup integer=%d name=%d\n", setup, setup_named);
    vpi_printf("vpiHold integer=%d name=%d\n", hold, hold_named);
    return 0;
}

static void setup(void)
{
    s_cb_data cb = {0};
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start;
    vpi_register_cb(&cb);

    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_operation_and_timing_names";
    task.calltf = inspect;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
