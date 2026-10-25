/* VPI application of test_vpi_compatibility_1364v2005_variable_objects
   (IEEE 1800-2023 36.12.1, 36.12.2.1, L.2). */
/* The one compatibility macro, defined as 1 before any VPI header. */
#define VPI_COMPATIBILITY_VERSION_1364v2005 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_compatibility_1364v2005_variable_objects"
#define MAX 8
#define LEN 64

#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)
#define SHOW(f) vpi_printf((PLI_BYTE8 *)"%s calls %s\n", #f, VT_XSTR(f))

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static vpiHandle find(const char *name)
{
    char full[160];
    vpiHandle h;
    if (name[0] != '\0')
        snprintf(full, sizeof full, "%s.%s", TOP, name);
    else
        snprintf(full, sizeof full, "%s", TOP);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", full);
    return h;
}

static void list(const char *label, PLI_INT32 type, vpiHandle ref)
{
    char names[MAX][LEN];
    vpiHandle it, h;
    int n = 0, i;

    if (ref == NULL)
        return;
    it = vpi_iterate(type, ref);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *s = vpi_get_str(vpiName, h);
        if (n < MAX)
            snprintf(names[n++], LEN, "%s", s ? s : "(null)");
    }
    qsort(names, n, LEN, by_text);
    vpi_printf((PLI_BYTE8 *)"%s (%d):", label, n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)" %s", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
}

static const char *type_name(PLI_INT32 type)
{
    switch (type) {
    case vpiIntegerVar: return "vpiIntegerVar";
    case vpiTimeVar: return "vpiTimeVar";
    case vpiRealVar: return "vpiRealVar";
    case vpiRegArray: return "vpiRegArray";
    case vpiReg: return "vpiReg";
    case vpiMemory: return "vpiMemory";
    default: return "other";
    }
}

static void type_of(const char *name)
{
    vpiHandle h = find(name);
    if (h != NULL)
        vpi_printf((PLI_BYTE8 *)"type of %s: %s\n", name, type_name(vpi_get(vpiType, h)));
}

static PLI_INT32 compat_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    SHOW(vpi_iterate);
    SHOW(vpi_scan);
    SHOW(vpi_handle_by_name);
    SHOW(vpi_get);
    list("vpiVariables of the top module", vpiVariables, find(""));
    list("vpiRegArray of arrays", vpiRegArray, find("arrays"));
    type_of("arrays.ia");
    type_of("arrays.ta");
    type_of("arrays.ra");
    type_of("arrays.rmem");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_compat";
    d.calltf = compat_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
