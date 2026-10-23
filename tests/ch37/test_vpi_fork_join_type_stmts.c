/* VPI application of test_vpi_fork_join_type_stmts (IEEE 1800-2023 37.12). */
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

static int by_name(const void *a, const void *b)
{
    return strcmp(*(const char *const *)a, *(const char *const *)b);
}

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static const char *join_type(vpiHandle f)
{
    switch (vpi_get(vpiJoinType, f)) {
    case vpiJoin: return "vpiJoin";
    case vpiJoinAny: return "vpiJoinAny";
    case vpiJoinNone: return "vpiJoinNone";
    default: return "other join type";
    }
}

static void show_fork(vpiHandle f)
{
    vpiHandle it, s, lhs;
    char *names[MAX];
    int n = 0, i;

    if (vpi_get(vpiType, f) == vpiNamedFork)
        vpi_printf("named fork %s", copy(vpi_get_str(vpiName, f)));
    else if (vpi_get(vpiType, f) == vpiFork)
        vpi_printf("fork");
    else {
        vpi_printf("not a fork\n");
        return;
    }
    vpi_printf(", %s, statements:", join_type(f));
    it = vpi_iterate(vpiStmt, f);
    while (it && (s = vpi_scan(it)) != NULL) {
        lhs = vpi_get(vpiType, s) == vpiAssignment ? vpi_handle(vpiLhs, s) : NULL;
        if (n < MAX)
            names[n++] = lhs ? copy(vpi_get_str(vpiName, lhs)) : copy((PLI_BYTE8 *)"other");
    }
    qsort(names, n, sizeof names[0], by_name);
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    vpi_printf("\n");
}

static PLI_INT32 forks_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle p = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_fork_join_type_stmts.p", NULL);
    vpiHandle it = p ? vpi_iterate(vpiStmt, p) : NULL, s;
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
    vpi_printf("statements of p: %d\n", n);
    for (i = 0; i < n; i++)
        show_fork(list[i].h);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_forks";
    d.calltf = forks_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
