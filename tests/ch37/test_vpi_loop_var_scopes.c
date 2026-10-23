/* VPI application of test_vpi_loop_var_scopes (IEEE 1800-2023 37.12, 37.74, 37.75). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

struct stmt {
    int line;
    vpiHandle h;
};

static int by_line(const void *a, const void *b)
{
    return ((const struct stmt *)a)->line - ((const struct stmt *)b)->line;
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static void show_scope(vpiHandle s)
{
    if (s == NULL) {
        vpi_printf("NULL");
        return;
    }
    switch (vpi_get(vpiType, s)) {
    case vpiFor:
        vpi_printf("for (vpiLocalVarDecls %d)", (int)vpi_get(vpiLocalVarDecls, s));
        break;
    case vpiForeachStmt: vpi_printf("foreach stmt"); break;
    case vpiNamedBegin: vpi_printf("named begin %s", copy(vpi_get_str(vpiName, s))); break;
    case vpiModule: vpi_printf("module %s", copy(vpi_get_str(vpiName, s))); break;
    default: vpi_printf("other type"); break;
    }
}

static PLI_INT32 loop_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call);
    vpiHandle label = vpi_scan(args), var = vpi_scan(args);
    vpiHandle cs = vpi_handle(vpiScope, call), vs;
    s_vpi_value v;

    (void)user_data;
    vpi_free_object(args);
    v.format = vpiStringVal;
    vpi_get_value(label, &v);
    vpi_printf("%s: call in ", v.value.str);
    show_scope(cs);
    vs = vpi_handle(vpiScope, var);
    vpi_printf("; %s in the same scope %d", copy(vpi_get_str(vpiName, var)),
               cs != NULL && vs != NULL && vpi_compare_objects(cs, vs));
    if (vs != NULL && (cs == NULL || !vpi_compare_objects(cs, vs))) {
        vpi_printf(", in ");
        show_scope(vs);
    }
    vpi_printf("\n");
    return 0;
}

static PLI_INT32 fors_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle b = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_loop_var_scopes.b", NULL);
    vpiHandle it = b ? vpi_iterate(vpiStmt, b) : NULL, s;
    struct stmt list[MAX];
    int n = 0, i;

    (void)user_data;
    while (it && (s = vpi_scan(it)) != NULL) {
        if (n == MAX)
            continue;
        list[n].line = (int)vpi_get(vpiLineNo, s);
        list[n++].h = s;
    }
    qsort(list, n, sizeof list[0], by_line);
    vpi_printf("loops of b:");
    for (i = 0; i < n; i++) {
        PLI_INT32 t = vpi_get(vpiType, list[i].h);
        if (t == vpiFor || t == vpiForeachStmt) {
            vpi_printf(" ");
            show_scope(list[i].h);
        }
    }
    vpi_printf("\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_loop";
    d.calltf = loop_calltf;
    vpi_register_systf(&d);
    d.tfname = (PLI_BYTE8 *)"$vt_fors";
    d.calltf = fors_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
