/* VPI application of test_vpi_scan_iterators (IEEE 1800-2023 38.40). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define MAX_NAMES 16

typedef struct {
    int count;
    char names[MAX_NAMES][32];
} name_list;

static void add_name(name_list *list, const char *prefix, vpiHandle obj)
{
    const char *name = vpi_get_str(vpiName, obj);
    if (list->count < MAX_NAMES)
        snprintf(list->names[list->count], sizeof list->names[0], "%s%s", prefix,
                 name ? name : "?");
    list->count++;
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static void print_list(const char *label, name_list *list)
{
    int k, shown = list->count < MAX_NAMES ? list->count : MAX_NAMES;

    qsort(list->names, shown, sizeof list->names[0], by_text);
    vpi_printf("%s: %d:", label, list->count);
    for (k = 0; k < shown; k++)
        vpi_printf(" %s", list->names[k]);
    vpi_printf("\n");
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_scan_iterators", NULL);
    vpiHandle it, it1, it2, obj, mods, mod, u1;
    name_list all, first, second, nested;
    int first_done = 0, second_done = 0, modules = 0;

    (void)data;
    memset(&all, 0, sizeof all);
    memset(&first, 0, sizeof first);
    memset(&second, 0, sizeof second);
    memset(&nested, 0, sizeof nested);
    if (top == NULL) {
        vpi_printf("top module not found\n");
        return 0;
    }

    it = vpi_iterate(vpiReg, top);
    while (it != NULL && (obj = vpi_scan(it)) != NULL)
        add_name(&all, "", obj);
    print_list("variables of the top module", &all);

    it1 = vpi_iterate(vpiReg, top);
    it2 = vpi_iterate(vpiReg, top);
    if (it1 == NULL || it2 == NULL) {
        vpi_printf("no iterators\n");
        return 0;
    }
    while (!first_done || !second_done) {
        if (!first_done) {
            obj = vpi_scan(it1);
            if (obj == NULL)
                first_done = 1;
            else
                add_name(&first, "", obj);
        }
        /* the second iterator advances twice for each step of the first */
        for (int k = 0; k < 2 && !second_done; k++) {
            obj = vpi_scan(it2);
            if (obj == NULL)
                second_done = 1;
            else
                add_name(&second, "", obj);
        }
    }
    print_list("first of two iterators", &first);
    print_list("second of two iterators", &second);

    mods = vpi_iterate(vpiModule, top);
    while (mods != NULL && (mod = vpi_scan(mods)) != NULL) {
        char prefix[40];
        const char *name = vpi_get_str(vpiName, mod);
        modules++;
        snprintf(prefix, sizeof prefix, "%s.", name ? name : "?");
        it = vpi_iterate(vpiReg, mod);
        while (it != NULL && (obj = vpi_scan(it)) != NULL)
            add_name(&nested, prefix, obj);
    }
    vpi_printf("instances: %d\n", modules);
    print_list("variables of the instances", &nested);

    u1 = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_scan_iterators.u1", NULL);
    vpi_printf("vpi_iterate of the instances of u1: %s\n",
               u1 == NULL ? "u1 not found" : vpi_iterate(vpiModule, u1) == NULL ? "NULL"
               : "an iterator");
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
