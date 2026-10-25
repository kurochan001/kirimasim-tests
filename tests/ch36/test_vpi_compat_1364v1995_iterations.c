/* VPI application of test_vpi_compat_1364v1995_iterations
   (IEEE 1800-2023 36.12.1, 36.12.2.1, L.2). */
/* The compatibility mode 1364v1995, selected before any VPI header (36.12.2.1). */
#define VPI_COMPATIBILITY_VERSION_1364v1995 1
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_compat_1364v1995_iterations"
#define MAX_ITEMS 16

/* The application's own names: vpiLogicVar is vpiReg, vpiArrayVar is vpiRegArray. */
static const char *type_name(PLI_INT32 type)
{
    switch (type) {
    case vpiReg: return "vpiReg";
    case vpiRegArray: return "vpiRegArray";
    case vpiMemory: return "vpiMemory";
    case vpiMemoryWord: return "vpiMemoryWord";
    case vpiIntegerVar: return "vpiIntegerVar";
    case vpiTimeVar: return "vpiTimeVar";
    case vpiRealVar: return "vpiRealVar";
    default: return "other";
    }
}

typedef struct {
    int count;
    char items[MAX_ITEMS][48];
} text_list;

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void append(text_list *list, const char *text)
{
    if (list->count < MAX_ITEMS)
        snprintf(list->items[list->count], sizeof list->items[0], "%s", text);
    list->count++;
}

static void print_items(text_list *list, const char *sep)
{
    int k, shown = list->count < MAX_ITEMS ? list->count : MAX_ITEMS;
    qsort(list->items, shown, sizeof list->items[0], by_text);
    for (k = 0; k < shown; k++)
        vpi_printf((PLI_BYTE8 *)"%s%s", k ? sep : "", list->items[k]);
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *type_of(const char *name)
{
    vpiHandle h = find(name);
    return h == NULL ? "not found" : type_name(vpi_get(vpiType, h));
}

static int is_named(vpiHandle obj, const char *name)
{
    const char *n = vpi_get_str(vpiName, obj);
    return n != NULL && strcmp(n, name) == 0;
}

/* The vpiVariables iteration of the module: whether the plain integer, real
   and time variables are among it, and whether the reg variable, the reg
   array or any vpiReg or vpiRegArray object is. */
static void show_variables(vpiHandle top)
{
    vpiHandle it, obj;
    int iv = 0, rv = 0, tv = 0, rg = 0, mem = 0, regs = 0;

    it = vpi_iterate(vpiVariables, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        PLI_INT32 type = vpi_get(vpiType, obj);
        iv |= is_named(obj, "iv");
        rv |= is_named(obj, "rv");
        tv |= is_named(obj, "tv");
        rg |= is_named(obj, "rg");
        mem |= is_named(obj, "mem");
        regs |= type == vpiReg || type == vpiRegArray;
    }
    vpi_printf((PLI_BYTE8 *)"vpiVariables contains iv rv tv: %d\n",
               iv && rv && tv);
    vpi_printf((PLI_BYTE8 *)"rg in vpiVariables: %d, mem in vpiVariables: %d\n",
               rg, mem);
    vpi_printf((PLI_BYTE8 *)"vpiReg or vpiRegArray in vpiVariables: %d\n", regs);
}

/* The vpiRegArray iteration of the module and the vpiReg iteration on each
   object it gives. */
static void show_reg_arrays(vpiHandle top)
{
    text_list names;
    vpiHandle it, obj;
    int arrays = 0, elements = 0;

    memset(&names, 0, sizeof names);
    it = vpi_iterate(vpiRegArray, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL) {
        const char *name = vpi_get_str(vpiName, obj);
        vpiHandle eit = vpi_iterate(vpiReg, obj), elem;
        append(&names, name ? name : "?");
        arrays++;
        while (eit != NULL && (elem = vpi_scan(eit)) != NULL)
            elements++;
    }
    vpi_printf((PLI_BYTE8 *)"vpiRegArray of the module: ");
    if (arrays == 0)
        vpi_printf((PLI_BYTE8 *)"NULL");
    else
        print_items(&names, " ");
    vpi_printf((PLI_BYTE8 *)"\nvpiReg of each vpiRegArray: %d arrays, %d objects\n",
               arrays, elements);
}

static PLI_INT32 compat_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle mem, word, rg;
    s_vpi_value v;

    (void)user_data;
    if (top == NULL) {
        vpi_printf((PLI_BYTE8 *)"top module not found\n");
        return 0;
    }

    vpi_printf((PLI_BYTE8 *)"types: mem %s, ia %s, ta %s, rg %s, iv %s, tv %s, rv %s\n",
               type_of("mem"), type_of("ia"), type_of("ta"), type_of("rg"),
               type_of("iv"), type_of("tv"), type_of("rv"));

    show_variables(top);
    show_reg_arrays(top);

    /* A value through a vpiMemoryWord handle and through the reg variable:
       both objects exist and can be read in this mode. */
    mem = find("mem");
    rg = find("rg");
    word = mem == NULL ? NULL : vpi_handle_by_index(mem, 0);
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    if (word != NULL)
        vpi_get_value(word, &v);
    vpi_printf((PLI_BYTE8 *)"read: mem[0] %s %d, ",
               word == NULL ? "none" : type_name(vpi_get(vpiType, word)),
               word == NULL ? -1 : (int)v.value.integer);
    memset(&v, 0, sizeof v);
    v.format = vpiIntVal;
    if (rg != NULL)
        vpi_get_value(rg, &v);
    vpi_printf((PLI_BYTE8 *)"rg %d\n", rg == NULL ? -1 : (int)v.value.integer);
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
