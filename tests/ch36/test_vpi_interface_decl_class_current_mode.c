/* VPI application of test_vpi_interface_decl_class_current_mode (IEEE 1800-2023 36.12.1). */
/* No VPI_COMPATIBILITY_VERSION_ macro is defined: the current behavior. */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_decl_class_current_mode"

static const char *type_name(PLI_INT32 type)
{
    switch (type) {
    case vpiVirtualInterfaceVar: return "vpiVirtualInterfaceVar";
    case vpiRefObj: return "vpiRefObj";
    case vpiClassTypespec: return "vpiClassTypespec";
    case vpiClassDefn: return "vpiClassDefn";
    default: return "other";
    }
}

static int is_named(vpiHandle obj, const char *name)
{
    const char *n = vpi_get_str(vpiName, obj);
    return n != NULL && strcmp(n, name) == 0;
}

/* Prints each object of the iteration as name and type, or NULL. */
static void show(const char *label, PLI_INT32 relation, vpiHandle ref)
{
    vpiHandle it = ref == NULL ? NULL : vpi_iterate(relation, ref), obj;
    vpi_printf("%s:", label);
    if (it == NULL)
        vpi_printf(" NULL");
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, obj);
        vpi_printf(" %s %s", name ? name : "?", type_name(vpi_get(vpiType, obj)));
    }
    vpi_printf("\n");
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle h = vpi_handle_by_name((PLI_BYTE8 *)TOP ".h", NULL);
    vpiHandle it, obj, defn = NULL, ts;

    (void)data;
    vpi_printf("vpiInterfaceDecl is vpiVirtualInterfaceVar: %d\n",
               vpiInterfaceDecl == vpiVirtualInterfaceVar);
    it = top == NULL ? NULL : vpi_iterate(vpiClassDefn, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL)
        if (is_named(obj, "holder"))
            defn = obj;
    vpi_printf("class defn holder found: %d\n", defn != NULL);
    if (defn != NULL)
        show("vpiInterfaceDecl of the class defn", vpiInterfaceDecl, defn);

    ts = h == NULL ? NULL : vpi_handle(vpiTypespec, h);
    vpi_printf("typespec of h: %s\n", ts == NULL ? "NULL" : type_name(vpi_get(vpiType, ts)));
    show("vpiInterfaceDecl of the class typespec", vpiInterfaceDecl, ts);
    return 0;
}

static void register_start(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_start, 0};

#ifdef __cplusplus
}
#endif
