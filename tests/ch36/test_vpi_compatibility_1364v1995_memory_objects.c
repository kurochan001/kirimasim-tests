/* VPI application of test_vpi_compatibility_1364v1995_memory_objects
   (IEEE 1800-2023 36.12.1, 36.12.2.1, L.2). */
/* The one compatibility macro, defined as 1 before any VPI header. */
#define VPI_COMPATIBILITY_VERSION_1364v1995 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_compatibility_1364v1995_memory_objects"

#define VT_STR(x) #x
#define VT_XSTR(x) VT_STR(x)
#define SHOW(f) vpi_printf((PLI_BYTE8 *)"%s calls %s\n", #f, VT_XSTR(f))

static const char *type_name(PLI_INT32 type)
{
    switch (type) {
    case vpiMemory: return "vpiMemory";
    case vpiMemoryWord: return "vpiMemoryWord";
    case vpiIntegerVar: return "vpiIntegerVar";
    case vpiRegArray: return "vpiRegArray";
    case vpiReg: return "vpiReg";
    default: return "other";
    }
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

/* Prints the number of objects of an iteration and their types; all of
   them are expected to have the same type. */
static void types_of(const char *label, PLI_INT32 rel, vpiHandle ref)
{
    vpiHandle it = ref != NULL ? vpi_iterate(rel, ref) : NULL, h;
    int n = 0, same = 1;
    PLI_INT32 first = 0;

    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_INT32 t = vpi_get(vpiType, h);
        if (n++ == 0)
            first = t;
        else if (t != first)
            same = 0;
    }
    vpi_printf((PLI_BYTE8 *)"%s: %d of type %s\n", label, n,
               n == 0 ? "(none)" : same ? type_name(first) : "(mixed)");
}

static PLI_INT32 compat_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top, mem, ia, word;
    s_vpi_value v;

    (void)user_data;
    SHOW(vpi_handle_by_name);
    SHOW(vpi_handle_by_index);
    SHOW(vpi_iterate);
    SHOW(vpi_scan);
    SHOW(vpi_get);
    SHOW(vpi_get_value);
    top = find("");
    mem = find("mem");
    ia = find("ia");
    if (top == NULL || mem == NULL || ia == NULL)
        return 0;
    vpi_printf((PLI_BYTE8 *)"type of mem: %s\n", type_name(vpi_get(vpiType, mem)));
    types_of("vpiMemory of the module", vpiMemory, top);
    types_of("vpiMemoryWord of mem", vpiMemoryWord, mem);
    word = vpi_handle_by_index(mem, 1);
    if (word == NULL) {
        vpi_printf((PLI_BYTE8 *)"vpi_handle_by_index(mem, 1): (none)\n");
    } else {
        v.format = vpiIntVal;
        vpi_get_value(word, &v);
        vpi_printf((PLI_BYTE8 *)"vpi_handle_by_index(mem, 1): %s, value %d\n",
                   type_name(vpi_get(vpiType, word)), (int)v.value.integer);
    }
    vpi_printf((PLI_BYTE8 *)"type of ia: %s\n", type_name(vpi_get(vpiType, ia)));
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
