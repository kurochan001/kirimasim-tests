/* VPI application of test_vpi_variable_parent_prefixes (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_parent_prefixes"

/* vpi_get_str reuses its buffer (38.11), so every string is copied; NULL is shown. */
static char *str(PLI_BYTE8 *s)
{
    const char *t = s ? s : "NULL";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static vpiHandle child(PLI_INT32 rel, vpiHandle ref, const char *name)
{
    vpiHandle it = ref ? vpi_iterate(rel, ref) : NULL, h, found = NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        PLI_BYTE8 *n = vpi_get_str(vpiName, h);
        if (found == NULL && n != NULL && strcmp(n, name) == 0)
            found = h;
    }
    return found;
}

static const char *parent_name(vpiHandle h)
{
    vpiHandle p = vpi_handle(vpiParent, h);
    return p ? str(vpi_get_str(vpiName, p)) : "NULL";
}

/* Names, parent and constant select of a variable. */
static void names(const char *label, vpiHandle h, vpiHandle parent, const char *pname)
{
    if (h == NULL) {
        vpi_printf("%s: not found\n", label);
        return;
    }
    vpi_printf("%s: name %s, full name %s, decompiled %s, parent %s (is %s %d), "
               "constant select %d\n", label, str(vpi_get_str(vpiName, h)),
               str(vpi_get_str(vpiFullName, h)), str(vpi_get_str(vpiDecompile, h)),
               parent_name(h), pname, same(vpi_handle(vpiParent, h), parent),
               (int)vpi_get(vpiConstantSelect, h));
}

static void no_parent(const char *name)
{
    vpiHandle h = find(name);
    vpi_printf("%s: parent %s, constant select %d\n", name, h ? parent_name(h) : "not found",
               h ? (int)vpi_get(vpiConstantSelect, h) : -1);
}

static PLI_INT32 parents_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle ra = find("ra"), un = find("un"), mv = find("mv"), obj = find("obj");
    vpiHandle ra1, k, w, in, w0, c, raw, hl, h, mv2, it, b, defn, a[5];
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    int n = 0, bits = 0, bit_parent = 0, bit_constant = 0;

    (void)user_data;
    if (top == NULL || ra == NULL || un == NULL || mv == NULL || obj == NULL || call == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    no_parent("solo");
    no_parent("ra");
    no_parent("un");
    no_parent("mv");
    no_parent("obj");

    ra1 = vpi_handle_by_index(ra, 1);
    names("ra[1]", ra1, ra, "ra");
    k = child(vpiMember, ra1, "k");
    w = child(vpiMember, ra1, "w");
    in = child(vpiMember, ra1, "in");
    names("ra[1].k", k, ra1, "ra[1]");
    names("ra[1].w", w, ra1, "ra[1]");
    names("ra[1].in", in, ra1, "ra[1]");
    w0 = w ? vpi_handle_by_index(w, 0) : NULL;
    names("ra[1].w[0]", w0, w, "w");
    c = child(vpiMember, in, "c");
    names("ra[1].in.c", c, in, "in");
    vpi_printf("ra[1].in.c by full name from the top %d, by decompiled name in the module %d\n",
               same(c, vpi_handle_by_name((PLI_BYTE8 *)TOP ".ra[1].in.c", NULL)),
               same(c, vpi_handle_by_name((PLI_BYTE8 *)"ra[1].in.c", top)));

    raw = child(vpiMember, un, "raw");
    hl = child(vpiMember, un, "hl");
    names("un.raw", raw, un, "un");
    names("un.hl", hl, un, "un");
    h = child(vpiMember, hl, "h");
    names("un.hl.h", h, hl, "hl");

    mv2 = vpi_handle_by_index(mv, 2);
    names("mv[2]", mv2, mv, "mv");
    it = mv2 ? vpi_iterate(vpiBit, mv2) : NULL;
    while (it != NULL && (b = vpi_scan(it)) != NULL) {
        bits++;
        bit_parent += same(vpi_handle(vpiParent, b), mv2);
        bit_constant += (int)vpi_get(vpiConstantSelect, b);
    }
    vpi_printf("bits of mv[2]: %d, with mv[2] as parent %d, constant select %d\n", bits,
               bit_parent, bit_constant);

    it = vpi_iterate(vpiArgument, call);
    while (it != NULL && (b = vpi_scan(it)) != NULL)
        if (n < 5)
            a[n++] = b;
    if (n != 5) {
        vpi_printf("arguments: %d\n", n);
        return 0;
    }
    names("argument obj.m", a[0], obj, "obj");
    vpi_printf("argument obj.m: value %d\n", int_value(a[0]));
    vpi_printf("argument obj.sm: full name %s, value %d\n", str(vpi_get_str(vpiFullName, a[1])),
               int_value(a[1]));
    vpi_printf("argument pc::sm: full name %s, value %d\n", str(vpi_get_str(vpiFullName, a[2])),
               int_value(a[2]));
    vpi_printf("argument ra[k].k: constant select %d, value %d\n",
               (int)vpi_get(vpiConstantSelect, a[3]), int_value(a[3]));
    vpi_printf("argument ra[1].k: constant select %d, value %d\n",
               (int)vpi_get(vpiConstantSelect, a[4]), int_value(a[4]));

    b = child(vpiVariables, vpi_handle(vpiClassObj, obj), "m");
    vpi_printf("m from the class object of obj: %s, parent %s, value %d\n", b ? "found" : "NULL",
               b ? parent_name(b) : "-", b ? int_value(b) : -1);
    defn = child(vpiClassDefn, top, "pc");
    b = child(vpiVariables, defn, "m");
    vpi_printf("m from the class defn pc: %s, parent %s\n", b ? "found" : "NULL",
               b ? parent_name(b) : "-");

    b = vpi_handle_by_index(find("da"), 0);
    vpi_printf("da[0]: constant select %d\n", b ? (int)vpi_get(vpiConstantSelect, b) : -1);
    b = child(vpiMember, vpi_handle_by_index(find("rd"), 0), "k");
    vpi_printf("rd[0].k: constant select %d\n", b ? (int)vpi_get(vpiConstantSelect, b) : -1);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_parents";
    d.calltf = parents_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
