/* VPI application of test_vpi_null_reference_relations (IEEE 1800-2023 37.4.3, 37.5, 37.42). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX 16
#define LEN 80

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void print_sorted(const char *label, char names[][LEN], int n)
{
    int i;
    qsort(names, n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s (%d):", label, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

/* Double arrow from a circle to module: vpi_iterate(vpiModule, NULL). */
static void top_modules(void)
{
    char names[MAX][LEN];
    vpiHandle it = vpi_iterate(vpiModule, NULL), h;
    int n = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", s ? s : "(null)");
    }
    print_sorted("vpi_iterate(vpiModule, NULL)", names, n);
}

/* Double arrow from a circle to user systf: vpi_iterate(vpiUserSystf, NULL),
   keeping the names that start with $vt_. */
static void user_systfs(void)
{
    char names[MAX][LEN];
    vpiHandle it = vpi_iterate(vpiUserSystf, NULL), h;
    int n = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        s_vpi_systf_data d;
        memset(&d, 0, sizeof d);
        vpi_get_systf_info(h, &d);
        if (d.tfname != NULL && strncmp(d.tfname, "$vt_", 4) == 0 && n < MAX)
            snprintf(names[n++], LEN, "%s", d.tfname);
    }
    print_sorted("vpi_iterate(vpiUserSystf, NULL), $vt_ names", names, n);
}

static PLI_INT32 root_calltf(PLI_BYTE8 *user_data)
{
    static int calls = 0;
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL), it, arg, systf;
    char name[LEN];
    PLI_BYTE8 *s;
    s_vpi_value v;
    s_vpi_systf_data d;

    (void)user_data;
    if (call == NULL) {
        vpi_printf((PLI_BYTE8 *)"vpi_handle(vpiSysTfCall, NULL): (none)\n");
        return 0;
    }
    s = vpi_get_str(vpiName, call);
    snprintf(name, sizeof name, "%s", s ? s : "(null)");
    v.format = vpiIntVal;
    v.value.integer = -1;
    it = vpi_iterate(vpiArgument, call);
    arg = it != NULL ? vpi_scan(it) : NULL;
    if (arg != NULL) {
        vpi_get_value(arg, &v);
        vpi_free_object(it);
    }
    systf = vpi_handle(vpiUserSystf, call);
    memset(&d, 0, sizeof d);
    if (systf != NULL)
        vpi_get_systf_info(systf, &d);
    vpi_printf((PLI_BYTE8 *)"vpi_handle(vpiSysTfCall, NULL): %s on line %d, argument %d,"
               " user systf %s\n", name, (int)vpi_get(vpiLineNo, call), (int)v.value.integer,
               d.tfname != NULL ? d.tfname : "(none)");
    if (++calls == 1) {
        top_modules();
        user_systfs();
    }
    return 0;
}

static PLI_INT32 seven_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    s_vpi_value v;

    (void)user_data;
    v.format = vpiIntVal;
    v.value.integer = 7;
    vpi_put_value(call, &v, NULL, vpiNoDelay);
    return 0;
}

static PLI_INT32 seven_sizetf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    return 32;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_root";
    d.calltf = root_calltf;
    vpi_register_systf(&d);

    memset(&d, 0, sizeof d);
    d.type = vpiSysFunc;
    d.sysfunctype = vpiIntFunc;
    d.tfname = (PLI_BYTE8 *)"$vt_seven";
    d.calltf = seven_calltf;
    d.sizetf = seven_sizetf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
