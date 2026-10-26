/* VPI application of test_vpi_io_direction_undefined (IEEE 1800-2023 37.13). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_io_direction_undefined"

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static vpiHandle by_name(const char *path)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, path);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void decls(const char *label, vpiHandle owner)
{
    vpiHandle it = owner != NULL ? vpi_iterate(vpiIODecl, owner) : NULL, h;

    if (it == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: no io declaration\n", label);
        return;
    }
    while ((h = vpi_scan(it)) != NULL) {
        vpiHandle expr = vpi_handle(vpiExpr, h);
        vpi_printf((PLI_BYTE8 *)"%s %s: direction %d, expr %s\n", label,
                   sprop(vpiName, h), (int)vpi_get(vpiDirection, h),
                   sprop(vpiType, expr));
    }
}

static vpiHandle find_task(vpiHandle scope, const char *name)
{
    vpiHandle it = scope != NULL ? vpi_iterate(vpiTaskFunc, scope) : NULL, h;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (strcmp(sprop(vpiName, h), name) == 0) {
            vpi_release_handle(it);
            return h;
        }
    return NULL;
}

static PLI_INT32 dir_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle task = find_task(top, "vt");

    (void)user_data;
    decls("u1", by_name("u1"));
    decls("u2", by_name("u2"));
    decls("u3", by_name("u3"));
    decls("task vt", task);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_dir";
    d.calltf = dir_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
