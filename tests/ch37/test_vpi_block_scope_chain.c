/* VPI application of test_vpi_block_scope_chain (IEEE 1800-2023 37.12, 37.42). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 8

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

/* Prints a scope; unnamed blocks have no name to print. */
static int show_scope(vpiHandle s)
{
    switch (vpi_get(vpiType, s)) {
    case vpiBegin: vpi_printf("begin"); return 0;
    case vpiFork: vpi_printf("fork"); return 0;
    case vpiNamedBegin: vpi_printf("named begin %s", copy(vpi_get_str(vpiName, s))); return 0;
    case vpiNamedFork: vpi_printf("named fork %s", copy(vpi_get_str(vpiName, s))); return 0;
    case vpiTask: vpi_printf("task %s", copy(vpi_get_str(vpiName, s))); return 0;
    case vpiModule: vpi_printf("module %s", copy(vpi_get_str(vpiName, s))); return 1;
    default: vpi_printf("other type"); return 1;
    }
}

static void variables(vpiHandle s)
{
    vpiHandle it = vpi_iterate(vpiVariables, s), h;
    char *names[MAX];
    int n = 0, i;

    while (it && (h = vpi_scan(it)) != NULL)
        if (n < MAX)
            names[n++] = copy(vpi_get_str(vpiName, h));
    qsort(names, n, sizeof names[0], by_name);
    vpi_printf("; its variables:");
    for (i = 0; i < n; i++)
        vpi_printf(" %s", names[i]);
    if (n == 0)
        vpi_printf(" none");
}

static PLI_INT32 chain_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call);
    vpiHandle s = vpi_handle(vpiScope, call), first = s;
    s_vpi_value v;
    int depth;

    (void)user_data;
    v.format = vpiStringVal;
    vpi_get_value(vpi_scan(args), &v);
    vpi_printf("%s:", v.value.str);
    vpi_free_object(args);
    for (depth = 0; s != NULL && depth < 6; depth++) {
        vpi_printf("%s", depth ? " < " : " ");
        if (show_scope(s))
            break;
        s = vpi_handle(vpiScope, s);
    }
    if (first != NULL)
        variables(first);
    vpi_printf("\n");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_chain";
    d.calltf = chain_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
