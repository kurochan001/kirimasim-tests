/* VPI application of test_vpi_scope_lifetimes (IEEE 1800-2023 37.3.7). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_scope_lifetimes"

static vpiHandle find(const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
}

static void show(const char *label, vpiHandle h)
{
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", label);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: automatic %d\n", label, (int)vpi_get(vpiAutomatic, h));
}

static vpiHandle class_defn(void)
{
    vpiHandle top = find(TOP);
    vpiHandle it = top != NULL ? vpi_iterate(vpiClassDefn, top) : NULL, h;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, h);
        if (name != NULL && strcmp(name, "C") == 0)
            return h;
    }
    return NULL;
}

static vpiHandle method(vpiHandle defn, const char *name)
{
    vpiHandle it = vpi_iterate(vpiMethods, defn), h;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        const char *n = vpi_get_str(vpiName, h);
        if (n != NULL && strcmp(n, name) == 0)
            return h;
    }
    return NULL;
}

static PLI_INT32 auto_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle defn = class_defn();
    vpiHandle ts = defn != NULL ? vpi_handle(vpiClassTypespec, defn) : NULL;

    (void)user_data;
    show("module m_auto", find(TOP ".u_ma"));
    show("module m_static", find(TOP ".u_ms"));
    show("interface i_auto", find(TOP ".u_ia"));
    show("interface i_static", find(TOP ".u_is"));
    show("program p_auto", find(TOP ".u_pa"));
    show("program p_static", find(TOP ".u_ps"));
    show("package p_auto", find("pk_auto"));
    show("package p_static", find("pk_static"));
    show("class C defn", defn);
    show("class C typespec", ts);
    show("class C method m", defn != NULL ? method(defn, "m") : NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_auto";
    d.calltf = auto_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
