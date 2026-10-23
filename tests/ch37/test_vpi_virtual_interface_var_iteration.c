/* VPI application of test_vpi_virtual_interface_var_iteration (IEEE 1800-2023 37.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

struct item {
    char *name;
    vpiHandle h;
};

static int by_name(const void *a, const void *b)
{
    return strcmp(((const struct item *)a)->name, ((const struct item *)b)->name);
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiVirtualInterfaceVar: return "vpiVirtualInterfaceVar";
    case vpiArrayVar: return "vpiArrayVar";
    default: return "other type";
    }
}

static void show(vpiHandle top, PLI_INT32 type, const char *tname, int with_scope)
{
    vpiHandle it = vpi_iterate(type, top), h, s;
    struct item list[MAX];
    int n = 0, i;

    while (it && (h = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].name = copy(vpi_get_str(vpiName, h));
        list[n++].h = h;
    }
    qsort(list, n, sizeof list[0], by_name);
    vpi_printf("%s:", tname);
    for (i = 0; i < n; i++) {
        vpi_printf("%s %s %s", i ? "," : "", list[i].name, kind(list[i].h));
        if (with_scope) {
            s = vpi_handle(vpiScope, list[i].h);
            vpi_printf(" in %s", s ? copy(vpi_get_str(vpiFullName, s)) : "NULL");
        }
    }
    if (n == 0)
        vpi_printf(" none");
    vpi_printf("\n");
}

static PLI_INT32 vifs_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top =
        vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_virtual_interface_var_iteration", NULL);

    (void)user_data;
    show(top, vpiVirtualInterfaceVar, "vpiVirtualInterfaceVar", 1);
    show(top, vpiVariables, "vpiVariables", 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_vifs";
    d.calltf = vifs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
