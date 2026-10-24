/* VPI application of test_vpi_typespec_kinds_more (IEEE 1800-2023 37.25, 37.29). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_typespec_kinds_more"

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

static const char *kind(vpiHandle t)
{
    if (t == NULL)
        return "NULL";
    switch (vpi_get(vpiType, t)) {
    case vpiShortRealTypespec: return "shortreal typespec";
    case vpiRealTypespec: return "real typespec";
    case vpiByteTypespec: return "byte typespec";
    case vpiShortIntTypespec: return "shortint typespec";
    case vpiIntTypespec: return "int typespec";
    case vpiLongIntTypespec: return "longint typespec";
    case vpiIntegerTypespec: return "integer typespec";
    case vpiClassTypespec: return "class typespec";
    case vpiStringTypespec: return "string typespec";
    case vpiUnionTypespec: return "union typespec";
    case vpiBitTypespec: return "bit typespec";
    case vpiPackedArrayTypespec: return "packed array typespec";
    case vpiEventTypespec: return "event typespec";
    case vpiInterfaceTypespec: return "interface typespec";
    case vpiEnumTypespec: return "enum typespec";
    case vpiArrayTypespec: return "array typespec";
    case vpiSequenceTypespec: return "sequence typespec";
    case vpiPropertyTypespec: return "property typespec";
    case vpiTypeParameter: return "type parameter";
    default: return "other type";
    }
}

static void typespec_of(const char *name, int with_name)
{
    vpiHandle v = find(name), t = v ? vpi_handle(vpiTypespec, v) : NULL;
    vpi_printf("%s: %s", name, kind(t));
    if (t != NULL && with_name)
        vpi_printf(", name %s", str(vpi_get_str(vpiName, t)));
    vpi_printf("\n");
}

static void formals(PLI_INT32 decl_type, PLI_INT32 formal_type, const char *decl_name)
{
    vpiHandle d = child(decl_type, vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), decl_name);
    vpiHandle it = d ? vpi_iterate(formal_type, d) : NULL, f;
    vpi_printf("formals of %s:", decl_name);
    while (it != NULL && (f = vpi_scan(it)) != NULL)
        vpi_printf(" %s (%s)", str(vpi_get_str(vpiName, f)), kind(vpi_handle(vpiTypespec, f)));
    vpi_printf("\n");
}

static void index_type(const char *name)
{
    vpiHandle v = find(name), t = v ? vpi_handle(vpiTypespec, v) : NULL;
    vpi_printf("%s: %s, index typespec %s\n", name, kind(t),
               t ? kind(vpi_handle(vpiIndexTypespec, t)) : "-");
}

static PLI_INT32 typespecs_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle t, base, it, c, defn, mem;
    int consts = 0, back = 0;

    (void)user_data;
    if (top == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    typespec_of("v_sr", 1);
    typespec_of("v_re", 1);
    typespec_of("v_by", 1);
    typespec_of("v_sh", 1);
    typespec_of("v_sht", 1);
    typespec_of("v_lg", 1);
    typespec_of("v_ig", 1);
    typespec_of("v_cl", 0);
    typespec_of("v_st", 1);
    typespec_of("v_un", 1);
    typespec_of("v_bt", 1);
    typespec_of("v_pa", 1);
    typespec_of("v_ev", 1);
    typespec_of("v_vi", 1);
    t = vpi_handle(vpiTypespec, find("v_vi"));
    vpi_printf("v_vi: interface typespec def name %s\n", t ? str(vpi_get_str(vpiDefName, t)) : "-");

    formals(vpiSequenceDecl, vpiSeqFormalDecl, "s_twice");
    formals(vpiPropertyDecl, vpiPropFormalDecl, "p_then");

    defn = child(vpiClassDefn, top, "tp_c");
    mem = child(vpiVariables, defn, "mem");
    t = mem ? vpi_handle(vpiTypespec, mem) : NULL;
    vpi_printf("tp_c::mem: %s, name %s\n", kind(t), t ? str(vpi_get_str(vpiName, t)) : "-");

    t = vpi_handle(vpiTypespec, find("ve"));
    base = t ? vpi_handle(vpiBaseTypespec, t) : NULL;
    vpi_printf("ve: %s, name %s, base typespec %s\n", kind(t), t ? str(vpi_get_str(vpiName, t)) : "-",
               kind(base));
    it = t ? vpi_iterate(vpiEnumConst, t) : NULL;
    while (it != NULL && (c = vpi_scan(it)) != NULL) {
        consts++;
        back += same(vpi_handle(vpiEnumTypespec, c), t);
    }
    vpi_printf("enum constants of be_t: %d, leading to be_t %d\n", consts, back);

    t = vpi_handle(vpiTypespec, find("v_sht"));
    vpi_printf("instance of the typespec sh_t is the module %d\n",
               t ? same(vpi_handle(vpiInstance, t), top) : 0);

    index_type("aa_s");
    index_type("aa_i");
    index_type("aa_w");
    index_type("sa");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_typespecs";
    d.calltf = typespecs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
