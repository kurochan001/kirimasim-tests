/* VPI application of test_vpi_struct_typespecs (IEEE 1800-2023 37.25, 37.26). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_struct_typespecs"
#define MAX_ITEMS 8

static char items[MAX_ITEMS][64];
static int n_items;

static int compare(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

/* Prints the collected items after the label, sorted, and clears them. */
static void print_items(const char *label)
{
    int i;
    qsort(items, (size_t)n_items, sizeof items[0], compare);
    vpi_printf((PLI_BYTE8 *)"%s:", label);
    for (i = 0; i < n_items; i++)
        vpi_printf((PLI_BYTE8 *)" %s", items[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    n_items = 0;
}

static void add_item(const char *text)
{
    if (n_items < MAX_ITEMS)
        snprintf(items[n_items++], sizeof items[0], "%s", text);
}

static const char *name_or_none(vpiHandle h)
{
    return h != NULL && vpi_get_str(vpiName, h) != NULL ? vpi_get_str(vpiName, h) : "(none)";
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static const char *typespec_kind(vpiHandle t)
{
    switch (vpi_get(vpiType, t)) {
    case vpiStructTypespec: return "struct typespec";
    case vpiUnionTypespec: return "union typespec";
    case vpiEnumTypespec: return "enum typespec";
    case vpiLogicTypespec: return "logic typespec";
    case vpiIntTypespec: return "int typespec";
    default: return "other typespec";
    }
}

static PLI_INT32 types_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle rv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".rv", NULL);
    vpiHandle uv = vpi_handle_by_name((PLI_BYTE8 *)TOP ".uv", NULL);
    vpiHandle it, h, ts, alias, mts, enum_ts = NULL;
    char buf[64];

    (void)user_data;
    if (rv == NULL || uv == NULL) {
        vpi_printf((PLI_BYTE8 *)"rv or uv not found\n");
        return 0;
    }
    vpi_printf((PLI_BYTE8 *)"rv: struct var %d, packed %d, size %d, value %d\n",
               vpi_get(vpiType, rv) == vpiStructVar, (int)vpi_get(vpiPacked, rv),
               (int)vpi_get(vpiSize, rv), int_value(rv));
    it = vpi_iterate(vpiMember, rv);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL) {
            snprintf(buf, sizeof buf, "%s=%d", name_or_none(h), int_value(h));
            add_item(buf);
        }
    print_items("members of rv");

    vpi_printf((PLI_BYTE8 *)"uv: union var %d, packed %d\n", vpi_get(vpiType, uv) == vpiUnionVar,
               (int)vpi_get(vpiPacked, uv));
    it = vpi_iterate(vpiMember, uv);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL)
            add_item(name_or_none(h));
    print_items("members of uv");

    ts = vpi_handle(vpiTypespec, rv);
    if (ts == NULL) {
        vpi_printf((PLI_BYTE8 *)"typespec of rv: NULL\n");
        return 0;
    }
    snprintf(buf, sizeof buf, "%s", name_or_none(ts));
    alias = vpi_handle(vpiTypedefAlias, ts);
    vpi_printf((PLI_BYTE8 *)"typespec of rv: %s, name %s, alias %s\n", typespec_kind(ts), buf,
               name_or_none(alias));
    it = vpi_iterate(vpiTypespecMember, ts);
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL) {
            mts = vpi_handle(vpiTypespec, h);
            snprintf(buf, sizeof buf, "%s:", name_or_none(h));
            snprintf(buf + strlen(buf), sizeof buf - strlen(buf), "%s(%s)",
                     mts ? typespec_kind(mts) : "NULL", name_or_none(mts));
            add_item(buf);
            if (mts != NULL && vpi_get(vpiType, mts) == vpiEnumTypespec)
                enum_ts = mts;
        }
    print_items("typespec members");

    it = enum_ts ? vpi_iterate(vpiEnumConst, enum_ts) : NULL;
    if (it != NULL)
        while ((h = vpi_scan(it)) != NULL) {
            snprintf(buf, sizeof buf, "%s=%d", name_or_none(h), int_value(h));
            add_item(buf);
        }
    print_items("enum constants");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_types";
    d.calltf = types_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
