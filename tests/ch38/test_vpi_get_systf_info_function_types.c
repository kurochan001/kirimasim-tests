/* VPI application of test_vpi_get_systf_info_function_types (IEEE 1800-2023 38.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle functions[4];
static char report_data[] = "report";
static char sized_data[] = "sized";
static char signed_data[] = "signed";

static PLI_INT32 function_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 function_compiletf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static PLI_INT32 function_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 12;
}

static PLI_INT32 report_compiletf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 0;
}

static const char *function_type(PLI_INT32 t)
{
    return t == vpiSizedFunc ? "vpiSizedFunc" : t == vpiSizedSignedFunc ? "vpiSizedSignedFunc"
           : t == vpiRealFunc ? "vpiRealFunc" : t == vpiTimeFunc ? "vpiTimeFunc"
           : t == vpiIntFunc ? "vpiIntFunc" : "other";
}

static const char *routine(PLI_INT32 (*r)(PLI_BYTE8 *))
{
    return r == NULL ? "NULL" : r == function_calltf ? "function_calltf"
           : r == function_compiletf ? "function_compiletf"
           : r == function_sizetf ? "function_sizetf"
           : r == report_compiletf ? "report_compiletf" : "another";
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle systf = vpi_handle(vpiUserSystf, vpi_handle(vpiSysTfCall, NULL));
    s_vpi_systf_data d;
    int k;

    (void)user_data;
    memset(&d, 0, sizeof d);
    if (systf != NULL)
        vpi_get_systf_info(systf, &d);
    vpi_printf("%s: %s, compiletf %s, sizetf %s, user data \"%s\"\n",
               d.tfname ? d.tfname : "(no name)", d.type == vpiSysTask ? "task" : "other",
               routine(d.compiletf), routine(d.sizetf), d.user_data ? d.user_data : "(NULL)");
    for (k = 0; k < 4; k++) {
        memset(&d, 0, sizeof d);
        if (functions[k] != NULL)
            vpi_get_systf_info(functions[k], &d);
        vpi_printf("%s: %s, %s, calltf %s, compiletf %s, sizetf %s, user data \"%s\"\n",
                   d.tfname ? d.tfname : "(no name)", d.type == vpiSysFunc ? "function" : "other",
                   function_type(d.sysfunctype), routine(d.calltf), routine(d.compiletf),
                   routine(d.sizetf), d.user_data ? d.user_data : "(NULL)");
    }
    return 0;
}

static vpiHandle add(PLI_INT32 type, PLI_INT32 sysfunctype, const char *name,
                     PLI_INT32 (*calltf)(PLI_BYTE8 *), PLI_INT32 (*compiletf)(PLI_BYTE8 *),
                     PLI_INT32 (*sizetf)(PLI_BYTE8 *), PLI_BYTE8 *user_data)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = type;
    d.sysfunctype = sysfunctype;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    d.compiletf = compiletf;
    d.sizetf = sizetf;
    d.user_data = user_data;
    return vpi_register_systf(&d);
}

static void register_all(void)
{
    add(vpiSysTask, 0, "$vt_report", report_calltf, report_compiletf, NULL, report_data);
    functions[0] = add(vpiSysFunc, vpiSizedFunc, "$vt_sized", function_calltf,
                       function_compiletf, function_sizetf, sized_data);
    functions[1] = add(vpiSysFunc, vpiSizedSignedFunc, "$vt_signed", function_calltf, NULL,
                       function_sizetf, signed_data);
    functions[2] = add(vpiSysFunc, vpiRealFunc, "$vt_half", function_calltf, NULL, NULL, NULL);
    functions[3] = add(vpiSysFunc, vpiTimeFunc, "$vt_stamp", function_calltf, NULL, NULL, NULL);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
