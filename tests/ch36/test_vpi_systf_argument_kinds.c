/* VPI application of test_vpi_systf_argument_kinds (IEEE 1800-2023 36.4, 37.42). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

struct name {
    PLI_INT32 code;
    const char *text;
};

static const struct name types[] = {
    {vpiReg, "vpiReg"}, {vpiNet, "vpiNet"}, {vpiParameter, "vpiParameter"},
    {vpiConstant, "vpiConstant"}, {vpiSysFuncCall, "vpiSysFuncCall"}, {0, NULL}};

static const char *lookup(const struct name *names, PLI_INT32 code)
{
    static char other[32];
    for (; names->text != NULL; names++)
        if (names->code == code)
            return names->text;
    snprintf(other, sizeof other, "other (%d)", (int)code);
    return other;
}

static PLI_INT32 kinds_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle it = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, NULL));
    vpiHandle arg;
    s_vpi_value v;
    int n = 0;

    (void)user_data;
    while (it != NULL && (arg = vpi_scan(it)) != NULL) {
        PLI_INT32 type = vpi_get(vpiType, arg);
        n++;
        vpi_printf("%d: %s", n, lookup(types, type));
        if (type == vpiConstant && vpi_get(vpiConstType, arg) == vpiStringConst)
            vpi_printf(" vpiStringConst");
        else if (type == vpiReg || type == vpiNet || type == vpiParameter)
            vpi_printf(" %s", vpi_get_str(vpiFullName, arg));
        else if (type == vpiSysFuncCall)
            vpi_printf(" %s", vpi_get_str(vpiName, arg));
        v.format = type == vpiConstant && vpi_get(vpiConstType, arg) == vpiStringConst
                   ? vpiStringVal : vpiDecStrVal;
        vpi_get_value(arg, &v);
        vpi_printf(" = %s\n", v.value.str);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_kinds";
    d.calltf = kinds_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
