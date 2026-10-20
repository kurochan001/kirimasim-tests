/* VPI application of test_vpi_is_protected_property (IEEE 1800-2023 37.3.6, 38.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_is_protected_property"

static vpiHandle find(const char *name)
{
    char full[160];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void show(const char *label, vpiHandle h)
{
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s not found\n", label);
    else
        vpi_printf((PLI_BYTE8 *)"%s: protected %d, type known %d\n", label,
                   (int)vpi_get(vpiIsProtected, h), vpi_get(vpiType, h) > 0);
}

static PLI_INT32 protect_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle it = top ? vpi_iterate(vpiTaskFunc, top) : NULL;
    vpiHandle task = it ? vpi_scan(it) : NULL;

    (void)user_data;
    if (it != NULL && task != NULL)
        vpi_free_object(it);
    show("module", top);
    show("net w", find("w"));
    show("variable v", find("v"));
    show("task t", task);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_protect", protect_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
