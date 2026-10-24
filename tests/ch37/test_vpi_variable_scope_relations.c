/* VPI application of test_vpi_variable_scope_relations (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_scope_relations"
#define MAX 16

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int by_name(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static const char *name_of(vpiHandle h)
{
    return h ? copy(vpi_get_str(vpiName, h)) : "NULL";
}

static void variables(const char *label, vpiHandle ref)
{
    vpiHandle it = ref ? vpi_iterate(vpiVariables, ref) : NULL, h;
    char *names[MAX];
    int n = 0, i;

    while (it != NULL && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            names[n++] = copy(vpi_get_str(vpiName, h));
    qsort(names, n, sizeof names[0], by_name);
    vpi_printf("variables of %s (%d):", label, n);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
}

static void up(const char *label, vpiHandle var, vpiHandle instance, vpiHandle scope)
{
    vpiHandle i = vpi_handle(vpiInstance, var), s = vpi_handle(vpiScope, var);
    vpi_printf("%s: instance %s (expected one %d), scope %s (expected one %d)\n", label,
               name_of(i), same(i, instance), name_of(s), same(s, scope));
}

static PLI_INT32 vars_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle bus = find("bus"), blk = find("blk"), g = find("g");

    (void)user_data;
    if (top == NULL || bus == NULL || blk == NULL || g == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    variables("the module", top);
    variables("bus", bus);
    variables("blk", blk);
    variables("g", g);
    up("n", find("n"), top, top);
    up("bus.ii", find("bus.ii"), bus, bus);
    up("bus.il", find("bus.il"), bus, bus);
    up("blk.bv", find("blk.bv"), top, blk);
    up("g.gv", find("g.gv"), top, g);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_vars";
    d.calltf = vars_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
