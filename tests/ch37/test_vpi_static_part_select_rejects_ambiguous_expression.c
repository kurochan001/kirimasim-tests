#include <stdio.h>
#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int bound(vpiHandle part, PLI_INT32 relation)
{
    vpiHandle expression = vpi_handle(relation, part);
    s_vpi_value value = {0};
    if (expression == NULL)
        return -1;
    value.format = vpiIntVal;
    vpi_get_value(expression, &value);
    return (int)value.value.integer;
}

static int report(const char *label, vpiHandle part)
{
    if (part == NULL || vpi_get(vpiType, part) != vpiPartSelect) {
        vpi_printf("%s missing part-select\n", label);
        return 0;
    }
    int left = bound(part, vpiLeftRange);
    int right = bound(part, vpiRightRange);
    vpiHandle ambiguous = vpi_handle(vpiExpr, part);
    s_vpi_error_info error = {0};
    int reported = vpi_chk_error(&error) >= vpiError;
    vpi_printf("%s left=%d right=%d ambiguous null=%d error=%d\n",
               label, left, right, ambiguous == NULL, reported);
    return ambiguous == NULL && reported;
}

static PLI_INT32 observe(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle iterator = call != NULL ? vpi_iterate(vpiArgument, call) : NULL;
    (void)unused;
    if (iterator == NULL)
        return 0;

    vpiHandle ascending = vpi_scan(iterator);
    if (ascending == NULL)
        return 0;
    vpiHandle descending = vpi_scan(iterator);
    if (descending == NULL)
        return 0;

    int ascending_error = report("ascending", ascending);
    int descending_error = report("descending", descending);
    if (ascending_error && descending_error)
        fputs("VPI rejected the ambiguous part-select relation for ascending and descending\n", stderr);
    vpi_release_handle(iterator);
    return 0;
}

static void register_probe(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$probe_static_parts";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_probe, NULL};

#ifdef __cplusplus
}
#endif
