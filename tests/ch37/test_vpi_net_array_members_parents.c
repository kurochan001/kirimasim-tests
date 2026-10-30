/* VPI application of test_vpi_net_array_members_parents (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_array_members_parents"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiNet: return "logic net";
    case vpiNetBit: return "net bit";
    case vpiArrayNet: return "array net";
    case vpiPackedArrayNet: return "packed array net";
    case vpiStructNet: return "struct net";
    case vpiUnionNet: return "union net";
    case vpiIntNet: return "int net";
    case vpiIntegerNet: return "integer net";
    case vpiEnumNet: return "enum net";
    default: return "other net";
    }
}

static const char *name_of(vpiHandle h)
{
    const char *s = h != NULL ? vpi_get_str(vpiName, h) : NULL;
    return s != NULL ? s : "NULL";
}

/* Whether the value of a Boolean property is 0 or 1. */
static int is_boolean(PLI_INT32 property, vpiHandle h)
{
    PLI_INT32 v = vpi_get(property, h);
    return v == 0 || v == 1;
}

static void flags(const char *label, vpiHandle h)
{
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: NULL\n", label);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: %s size %d, array member %d, packed member %d, "
               "struct member %d, vpiArray bool %d\n",
               label, kind(h), (int)vpi_get(vpiSize, h),
               (int)vpi_get(vpiArrayMember, h),
               (int)vpi_get(vpiPackedArrayMember, h),
               (int)vpi_get(vpiStructUnionMember, h),
               is_boolean(vpiArray, h));
}

static void parent_is(const char *label, vpiHandle h, const char *wanted)
{
    vpiHandle p = h != NULL ? vpi_handle(vpiParent, h) : NULL;
    vpiHandle w = wanted != NULL ? find(wanted) : NULL;
    if (p == NULL && w == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: parent NULL\n", label);
        return;
    }
    vpi_printf((PLI_BYTE8 *)"%s: parent %s, is %s %d\n", label, name_of(p),
               wanted != NULL ? wanted : "NULL",
               p != NULL && w != NULL ? (int)vpi_compare_objects(p, w) : 0);
}

static void ranges(const char *label, vpiHandle h)
{
    vpiHandle it, r;
    s_vpi_value v;
    int n = 0;

    vpi_printf((PLI_BYTE8 *)"%s: ranges", label);
    it = h != NULL ? vpi_iterate(vpiRange, h) : NULL;
    while (it != NULL && (r = vpi_scan(it)) != NULL) {
        vpiHandle l = vpi_handle(vpiLeftRange, r);
        vpiHandle rr = vpi_handle(vpiRightRange, r);
        v.format = vpiIntVal;
        v.value.integer = -1;
        if (l != NULL)
            vpi_get_value(l, &v);
        vpi_printf((PLI_BYTE8 *)" %d:", (int)v.value.integer);
        v.value.integer = -1;
        if (rr != NULL)
            vpi_get_value(rr, &v);
        vpi_printf((PLI_BYTE8 *)"%d", (int)v.value.integer);
        n++;
    }
    vpi_printf((PLI_BYTE8 *)"%s\n", n == 0 ? " none" : "");
}

static void bits(const char *label, vpiHandle h)
{
    vpiHandle it, b;
    int n = 0, all_one = 1, same = 1;
    PLI_INT32 e = h != NULL ? vpi_get(vpiExpanded, h) : -2;

    it = h != NULL ? vpi_iterate(vpiBit, h) : NULL;
    while (it != NULL && (b = vpi_scan(it)) != NULL) {
        n++;
        if (vpi_get(vpiType, b) != vpiNetBit || vpi_get(vpiSize, b) != 1)
            all_one = 0;
        if (vpi_get(vpiExpanded, b) != e)
            same = 0;
    }
    vpi_printf((PLI_BYTE8 *)"%s: net bits %d, each size 1 %d, expanded is Boolean %d, "
               "each with the expanded value of the net %d\n",
               label, n, all_one, e == 0 || e == 1, n > 0 && same);
}

static void members(vpiHandle h)
{
    vpiHandle it, m;
    char names[4][32];
    int n = 0, i, j;

    it = h != NULL ? vpi_iterate(vpiMember, h) : NULL;
    while (it != NULL && (m = vpi_scan(it)) != NULL && n < 4)
        snprintf(names[n++], sizeof names[0], "%s", name_of(m));
    for (i = 0; i < n; i++)
        for (j = i + 1; j < n; j++)
            if (strcmp(names[i], names[j]) > 0) {
                char t[32];
                snprintf(t, sizeof t, "%s", names[i]);
                snprintf(names[i], sizeof names[i], "%s", names[j]);
                snprintf(names[j], sizeof names[j], "%s", t);
            }
    vpi_printf((PLI_BYTE8 *)"members:");
    if (n == 0)
        vpi_printf((PLI_BYTE8 *)" none");
    else {
        vpi_printf((PLI_BYTE8 *)" ");
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : "", names[i]);
    }
    vpi_printf((PLI_BYTE8 *)"\n");
}

static PLI_INT32 nets_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle vv4 = find("vv4"), sa = find("sa");
    vpiHandle sa_elem, m, bv = NULL, bv_elem, bit;
    PLI_INT32 i2[2] = {7, 9}, i4[4] = {7, 8, 1, 3}, p2[2] = {7, 8};
    PLI_INT32 s2[2] = {4, 1};

    (void)user_data;
    flags("vv4", vv4);
    flags("vv4[7][9]", vpi_handle_by_multi_index(vv4, 2, i2));
    bit = vpi_handle_by_multi_index(vv4, 4, i4);
    if (bit == NULL)
        vpi_printf((PLI_BYTE8 *)"vv4[7][8][1][3]: NULL\n");
    else
        vpi_printf((PLI_BYTE8 *)"vv4[7][8][1][3]: %s size %d\n", kind(bit),
                   (int)vpi_get(vpiSize, bit));
    m = vpi_handle_by_multi_index(vv4, 2, p2);
    flags("vv4[7][8]", m);
    if (bit != NULL && m != NULL)
        vpi_printf((PLI_BYTE8 *)"vv4[7][8][1][3]: parent is vv4[7][8] %d\n",
                   (int)vpi_compare_objects(vpi_handle(vpiParent, bit), m));
    parent_is("vv4[7][8]", m, "vv4");
    parent_is("vv4", vv4, NULL);

    sa_elem = vpi_handle_by_multi_index(sa, 2, s2);
    flags("sa[4][1]", sa_elem);
    members(sa_elem);
    vpiHandle it = sa_elem != NULL ? vpi_iterate(vpiMember, sa_elem) : NULL;
    while (it != NULL && (m = vpi_scan(it)) != NULL) {
        if (strcmp(name_of(m), "bv") == 0)
            bv = m;
        else if (strcmp(name_of(m), "id") == 0)
            flags("sa[4][1].id", m);
    }
    if (bv != NULL) {
        flags("sa[4][1].bv", bv);
        parent_is("sa[4][1].bv", bv, "sa[4][1]");
        bv_elem = vpi_handle_by_index(bv, 6);
        flags("sa[4][1].bv[6]", bv_elem);
        parent_is("sa[4][1].bv[6]", bv_elem, "sa[4][1].bv");
    }
    parent_is("sa[4][1]", sa_elem, "sa");
    parent_is("sa", sa, NULL);

    flags("un", find("un"));
    vpi_printf((PLI_BYTE8 *)"un: tagged %d\n", (int)vpi_get(vpiTagged, find("un")));
    flags("psa", find("psa"));
    flags("psa[1]", vpi_handle_by_index(find("psa"), 1));
    flags("pea", find("pea"));
    flags("pea[4]", vpi_handle_by_index(find("pea"), 4));
    flags("pua", find("pua"));
    flags("pua[3]", vpi_handle_by_index(find("pua"), 3));
    flags("ppa", find("ppa"));
    flags("ppa[1]", vpi_handle_by_index(find("ppa"), 1));
    ranges("psa", find("psa"));
    ranges("pea", find("pea"));
    ranges("pua", find("pua"));
    ranges("ppa", find("ppa"));
    bits("vv", find("vv"));
    bits("ss", find("ss"));
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_nets";
    d.calltf = nets_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
