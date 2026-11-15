/* VPI application of test_unnamed_block_scope_needs_declaration_vpi
 * (IEEE 1800-2023 9.3.4, 37.12). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_NAMES 16

/* The object types vpiBegin and vpiFork have these values in the vpi_user.h
 * of Annex K; they are defined here in case a tool's header leaves them
 * out. */
#ifndef vpiBegin
#define vpiBegin 4
#endif
#ifndef vpiFork
#define vpiFork 18
#endif

static int compare_names(const void *a, const void *b)
{
    return strcmp(*(char *const *)a, *(char *const *)b);
}

/* vpi_get_str may reuse its buffer, so a name that is kept is copied. */
static char *dup_name(vpiHandle h)
{
    PLI_BYTE8 *s = vpi_get_str(vpiName, h);
    const char *t = s != NULL ? s : "?";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

/* Prints one scope; returns 1 at the module, where the walk ends. */
static int print_scope(vpiHandle s)
{
    switch (vpi_get(vpiType, s)) {
    case vpiBegin:
        vpi_printf("begin");
        return 0;
    case vpiFork:
        vpi_printf("fork");
        return 0;
    case vpiNamedBegin:
        vpi_printf("named begin %s", dup_name(s));
        return 0;
    case vpiNamedFork:
        vpi_printf("named fork %s", dup_name(s));
        return 0;
    case vpiModule:
        vpi_printf("module %s", dup_name(s));
        return 1;
    default:
        vpi_printf("type %d", (int)vpi_get(vpiType, s));
        return 1;
    }
}

/* Prints the variables of a scope, sorted by name. */
static void print_variables(vpiHandle s)
{
    char *names[MAX_NAMES];
    int count = 0, i;
    vpiHandle it = vpi_iterate(vpiVariables, s), v;

    while (it != NULL && (v = vpi_scan(it)) != NULL)
        if (count < MAX_NAMES)
            names[count++] = dup_name(v);
    qsort(names, (size_t)count, sizeof names[0], compare_names);
    vpi_printf(" | variables:");
    if (count == 0)
        vpi_printf(" none");
    for (i = 0; i < count; i++)
        vpi_printf(" %s", names[i]);
}

/* $vt_where(label): the scope of the call and the scopes above it, up to
 * the module, and the variables of the scope of the call. */
static PLI_INT32 where_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle args = vpi_iterate(vpiArgument, call);
    vpiHandle scope = vpi_handle(vpiScope, call), s;
    s_vpi_value label;
    int steps;

    (void)user_data;
    label.format = vpiStringVal;
    vpi_get_value(vpi_scan(args), &label);
    vpi_printf("%s:", label.value.str);
    vpi_free_object(args);
    for (s = scope, steps = 0; s != NULL && steps < 8; steps++) {
        if (steps == 0)
            vpi_printf(" ");
        else
            vpi_printf(" < ");
        if (print_scope(s))
            break;
        s = vpi_handle(vpiScope, s);
    }
    if (scope != NULL)
        print_variables(scope);
    vpi_printf("\n");
    return 0;
}

static void register_where(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_where";
    d.calltf = where_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_where, 0};

#ifdef __cplusplus
}
#endif
