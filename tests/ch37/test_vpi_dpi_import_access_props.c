/* VPI application of test_vpi_dpi_import_access_props (IEEE 1800-2023 37.41). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_dpi_import_access_props"

/* Definitions of the imports, which the design never calls. */
int vt_dpi_pure(int a)
{
    return a;
}

int vt_dpi_ctx(int a)
{
    return a;
}

int vt_dpi_plain(int a)
{
    return a;
}

int vt_dpi_ctx_task(int a)
{
    (void)a;
    return 0;
}

static const char *access(PLI_INT32 a)
{
    switch (a) {
    case vpiDPIImportAcc: return "vpiDPIImportAcc";
    case vpiDPIExportAcc: return "vpiDPIExportAcc";
    default: return "other";
    }
}

static void show(const char *name)
{
    char full[96];
    vpiHandle tf;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    tf = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (tf == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: %s, access %s, pure %d, context %d\n", name,
               vpi_get(vpiType, tf) == vpiFunction ? "function"
               : vpi_get(vpiType, tf) == vpiTask ? "task" : "other",
               access(vpi_get(vpiAccessType, tf)), (int)vpi_get(vpiDPIPure, tf),
               (int)vpi_get(vpiDPIContext, tf));
}

static PLI_INT32 dpi_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("vt_dpi_pure");
    show("vt_dpi_ctx");
    show("vt_dpi_plain");
    show("vt_dpi_ctx_task");
    show("sv_exported");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_dpi";
    d.calltf = dpi_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
