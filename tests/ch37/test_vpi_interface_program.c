/* VPI application of test_vpi_interface_program (IEEE 1800-2023 37.6 to 37.9). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_program"

static char items[8][80];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void print_items(const char *label)
{
    int i;
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s:\n", label);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)"  %s\n", items[i]);
    n_items = 0;
}

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

static const char *direction(PLI_INT32 d)
{
    return d == vpiInput ? "input" : d == vpiOutput ? "output" : d == vpiInout ? "inout" : "other";
}

static int compare_decl(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

/* Adds a line with the modport's name and its io declarations, sorted. */
static void describe_modport(vpiHandle mp)
{
    char text[80], decls[4][32];
    vpiHandle it = vpi_iterate(vpiIODecl, mp), io;
    int n = 0, i;

    snprintf(text, sizeof text, "%s:", name_or_none(mp));
    if (it != NULL)
        while ((io = vpi_scan(it)) != NULL && n < 4) {
            snprintf(decls[n], sizeof decls[0], " %s", direction(vpi_get(vpiDirection, io)));
            snprintf(decls[n] + strlen(decls[n]), sizeof decls[0] - strlen(decls[n]), " %s",
                     name_or_none(io));
            n++;
        }
    qsort(decls, (size_t)n, sizeof decls[0], compare_decl);
    for (i = 0; i < n; i++)
        snprintf(text + strlen(text), sizeof text - strlen(text), "%s", decls[i]);
    if (n_items < 8)
        snprintf(items[n_items++], sizeof items[0], "%s", text);
}

static void describe_tf_decl(vpiHandle d)
{
    vpiHandle task = vpi_handle(vpiTask, d), func = vpi_handle(vpiFunction, d);
    PLI_INT32 access = vpi_get(vpiAccessType, d);

    if (n_items < 8)
        snprintf(items[n_items++], sizeof items[0], "%s: %s, %s",
                 task ? name_or_none(task) : name_or_none(func),
                 access == vpiForkJoinAcc ? "forkjoin" : access == vpiExternAcc ? "extern" :
                 "other access", task ? "task" : func ? "function" : "neither");
}

static PLI_INT32 instances_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), it, h, mp_it, mp, prog;
    int n = 0;

    (void)user_data;
    it = vpi_iterate(vpiInterface, top);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL) {
            char def[32];
            snprintf(def, sizeof def, "%s", vpi_get_str(vpiDefName, h));
            vpi_printf((PLI_BYTE8 *)"interface %s of %s\n", name_or_none(h), def);
            mp_it = vpi_iterate(vpiModport, h);
            if (mp_it != NULL)
                while ((mp = vpi_scan(mp_it)) != NULL)
                    describe_modport(mp);
            print_items("modports");
            mp_it = vpi_iterate(vpiInterfaceTfDecl, h);
            if (mp_it != NULL)
                while ((mp = vpi_scan(mp_it)) != NULL)
                    describe_tf_decl(mp);
            print_items("interface task and function declarations");
        }

    prog = vpi_handle_by_name((PLI_BYTE8 *)TOP ".p", NULL);
    it = prog ? vpi_iterate(vpiProcess, prog) : NULL;
    if (it != NULL)
        while (vpi_scan(it) != NULL)
            n++;
    vpi_printf((PLI_BYTE8 *)"p: program %d, definition %s, processes %d\n",
               prog != NULL && vpi_get(vpiType, prog) == vpiProgram,
               prog ? vpi_get_str(vpiDefName, prog) : "(none)", n);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_instances";
    d.calltf = instances_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
