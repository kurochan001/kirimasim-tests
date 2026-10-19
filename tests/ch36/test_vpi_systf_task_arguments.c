/* VPI application of test_vpi_systf_task_arguments (IEEE 1800-2023 36.4, 38.37). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 show_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle it = vpi_iterate(vpiArgument, call);
    vpiHandle arg;
    s_vpi_value v;
    int n = 0;

    (void)user_data;
    while ((arg = vpi_scan(it)) != NULL) {
        PLI_INT32 type = vpi_get(vpiType, arg);
        n++;
        if (type == vpiRealVar) {
            v.format = vpiRealVal;
            vpi_get_value(arg, &v);
            vpi_printf("argument %d: %s, real %.3f\n", n, vpi_get_str(vpiName, arg), v.value.real);
        } else if (type == vpiIntegerVar) {
            v.format = vpiIntVal;
            vpi_get_value(arg, &v);
            vpi_printf("argument %d: %s, integer %d\n",
                       n, vpi_get_str(vpiName, arg), (int)v.value.integer);
        } else if (type == vpiConstant && vpi_get(vpiConstType, arg) == vpiStringConst) {
            v.format = vpiStringVal;
            vpi_get_value(arg, &v);
            vpi_printf("argument %d: string \"%s\"\n", n, v.value.str);
        } else if (type == vpiReg) {
            v.format = vpiBinStrVal;
            vpi_get_value(arg, &v);
            vpi_printf("argument %d: %s, %d bits, %s\n",
                       n, vpi_get_str(vpiName, arg), (int)vpi_get(vpiSize, arg), v.value.str);
        } else {
            v.format = vpiDecStrVal;
            vpi_get_value(arg, &v);
            vpi_printf("argument %d: expression, %d bits, %s\n",
                       n, (int)vpi_get(vpiSize, arg), v.value.str);
        }
    }
    vpi_printf("%d arguments\n", n);
    return 0;
}

static void register_all(void)
{
{
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        d.type = vpiSysTask;
        d.sysfunctype = 0;
        d.tfname = (PLI_BYTE8 *)"$vt_show";
        d.calltf = show_calltf;
        d.sizetf = 0;
        d.user_data = (PLI_BYTE8 *)0;
        vpi_register_systf(&d);
    }
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
