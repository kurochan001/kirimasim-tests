/* VPI application of test_vpi_subroutine_body_stmt (IEEE 1800-2023 37.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_subroutine_body_stmt"
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

static void show_stmt(vpiHandle s)
{
    vpiHandle lhs;
    switch (vpi_get(vpiType, s)) {
    case vpiAssignment:
        lhs = vpi_handle(vpiLhs, s);
        vpi_printf("assignment to %s", lhs ? copy(vpi_get_str(vpiName, lhs)) : "?");
        break;
    case vpiReturnStmt: vpi_printf("return"); break;
    case vpiBegin: vpi_printf("begin"); break;
    case vpiNamedBegin: vpi_printf("named begin %s", copy(vpi_get_str(vpiName, s))); break;
    default: vpi_printf("other statement"); break;
    }
}

static void show(const char *name)
{
    char full[96];
    vpiHandle tf, body, scope, it, s;
    struct stmt list[MAX];
    int n = 0, i;

    snprintf(full, sizeof full, "%s.%s", TOP, name);
    tf = vpi_handle_by_name(full, NULL);
    if (tf == NULL) {
        vpi_printf("%s: not found\n", name);
        return;
    }
    scope = vpi_handle(vpiScope, tf);
    vpi_printf("%s: scope %s, vpiStmt ", name,
               scope ? copy(vpi_get_str(vpiFullName, scope)) : "NULL");
    body = vpi_handle(vpiStmt, tf);
    if (body == NULL) {
        vpi_printf("NULL\n");
        return;
    }
    show_stmt(body);
    if (vpi_get(vpiType, body) == vpiBegin || vpi_get(vpiType, body) == vpiNamedBegin) {
        it = vpi_iterate(vpiStmt, body);
        while (it && (s = vpi_scan(it)) != NULL) {
            if (n == MAX)
                continue;
            list[n].line = (int)vpi_get(vpiLineNo, s);
            list[n++].h = s;
        }
        qsort(list, n, sizeof list[0], by_line);
        vpi_printf(" holding");
        for (i = 0; i < n; i++) {
            vpi_printf("%s", i ? ", " : " ");
            show_stmt(list[i].h);
        }
    }
    vpi_printf("\n");
}

static PLI_INT32 bodies_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    show("t0");
    show("t1");
    show("t2");
    show("tn");
    show("f0");
    show("f1");
    show("f3");
    show("g.tg");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_bodies";
    d.calltf = bodies_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
