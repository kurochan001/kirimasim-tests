#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_legacy_class_interface_views"
#define SPELL(token) #token
#define ABI_NAME(token) SPELL(token)

typedef struct interface_view {
    int available;
    int count;
    int virtual_vars;
    int ref_objects;
    int actual_virtual_vars;
    int expected_names;
} interface_view;

static int named_member(vpiHandle item)
{
    const char *name = vpi_get_str(vpiName, item);
    if (name != NULL && strcmp(name, "main_link") == 0)
        return 1;
    if (name != NULL && strcmp(name, "backup_link") == 0)
        return 2;
    return 0;
}

static interface_view inspect(vpiHandle reference)
{
    interface_view counts = {0};
    vpiHandle iter = reference == NULL ? NULL : vpi_iterate(vpiInterfaceDecl, reference);
    vpiHandle item;
    counts.available = iter != NULL;
    while (iter != NULL && (item = vpi_scan(iter)) != NULL) {
        PLI_INT32 kind = vpi_get(vpiType, item);
        counts.count++;
        counts.expected_names |= named_member(item);
        if (kind == vpiVirtualInterfaceVar)
            counts.virtual_vars++;
        if (kind == vpiRefObj) {
            vpiHandle actual = vpi_handle(vpiActual, item);
            counts.ref_objects++;
            if (actual != NULL && vpi_get(vpiType, actual) == vpiVirtualInterfaceVar)
                counts.actual_virtual_vars++;
        }
    }
    return counts;
}

static void show(const char *label, interface_view view)
{
    vpi_printf("%s iter=%d count=%d virtual=%d ref=%d actual=%d name_mask=%d\n",
               label, view.available, view.count, view.virtual_vars,
               view.ref_objects, view.actual_virtual_vars, view.expected_names);
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle plain = vpi_handle_by_name((PLI_BYTE8 *)TOP ".plain", NULL);
    vpiHandle holder = vpi_handle_by_name((PLI_BYTE8 *)TOP ".holder", NULL);
    vpiHandle typespec = holder != NULL ? vpi_handle(vpiTypespec, holder) : NULL;
    vpiHandle class_iter = top != NULL ? vpi_iterate(vpiClassDefn, top) : NULL;
    vpiHandle item, defn = NULL;
    int plain_classes = 0;

    (void)data;
    while (class_iter != NULL && (item = vpi_scan(class_iter)) != NULL) {
        const char *name = vpi_get_str(vpiName, item);
        if (name != NULL && strcmp(name, "dual_view") == 0)
            defn = item;
    }
    class_iter = plain != NULL ? vpi_iterate(vpiClassDefn, plain) : NULL;
    while (class_iter != NULL && vpi_scan(class_iter) != NULL)
        plain_classes++;
    vpi_printf("abi=%s\n", ABI_NAME(vpi_iterate));
    vpi_printf("scopes defn=%d typespec=%d plain=%d plain_classes=%d\n",
               defn != NULL && vpi_get(vpiType, defn) == vpiClassDefn,
               typespec != NULL && vpi_get(vpiType, typespec) == vpiClassTypespec,
               plain != NULL && vpi_get(vpiType, plain) == vpiModule, plain_classes);
    show("defn", inspect(defn));
    show("typespec", inspect(typespec));
    return 0;
}

static void register_start(void)
{
    s_cb_data cb = {0};
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_start, NULL};
