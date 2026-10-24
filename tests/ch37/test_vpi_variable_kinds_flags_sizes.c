/* VPI application of test_vpi_variable_kinds_flags_sizes (IEEE 1800-2023 37.17). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_variable_kinds_flags_sizes"

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
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

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiShortRealVar: return "shortreal var";
    case vpiEnumVar: return "enum var";
    case vpiStringVar: return "string var";
    case vpiChandleVar: return "chandle var";
    case vpiClassVar: return "class var";
    case vpiVirtualInterfaceVar: return "virtual interface var";
    case vpiLogicVar: return "logic var";
    case vpiBitVar: return "bit var";
    case vpiIntegerVar: return "integer var";
    case vpiTimeVar: return "time var";
    case vpiShortIntVar: return "shortint var";
    case vpiIntVar: return "int var";
    case vpiLongIntVar: return "longint var";
    case vpiByteVar: return "byte var";
    case vpiRealVar: return "real var";
    case vpiStructVar: return "struct var";
    case vpiUnionVar: return "union var";
    case vpiArrayVar: return "array var";
    case vpiVarBit: return "var bit";
    default: return "other type";
    }
}

enum { SIZE = 1, GROUP = 2 };

static void flags(const char *label, vpiHandle h, int what)
{
    if (h == NULL) {
        vpi_printf("%s: not found\n", label);
        return;
    }
    vpi_printf("%s: %s, scalar %d, vector %d", label, kind(h), (int)vpi_get(vpiScalar, h),
               (int)vpi_get(vpiVector, h));
    if (what & SIZE)
        vpi_printf(", size %d", (int)vpi_get(vpiSize, h));
    if (what & GROUP)
        vpi_printf(", name %s, full name %s, scope is the module %d",
                   copy(vpi_get_str(vpiName, h)), copy(vpi_get_str(vpiFullName, h)),
                   same(vpi_handle(vpiScope, h), vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL)));
    vpi_printf("\n");
}

static void var(const char *name, int what)
{
    flags(name, find(name), what);
}

static vpiHandle first_bit(vpiHandle h)
{
    vpiHandle it = h ? vpi_iterate(vpiBit, h) : NULL, b;
    if (it == NULL)
        return NULL;
    b = vpi_scan(it);
    if (b != NULL)
        vpi_release_handle(it);
    return b;
}

static void membership(const char *label, vpiHandle h)
{
    if (h == NULL) {
        vpi_printf("%s: NULL\n", label);
        return;
    }
    vpi_printf("%s: %s, array var %d, array member %d\n", label, kind(h),
               vpi_get(vpiType, h) == vpiArrayVar ? 1 : 0, (int)vpi_get(vpiArrayMember, h));
}

static int one_of(vpiHandle h, const char *a, const char *b)
{
    PLI_BYTE8 *s = h ? vpi_get_str(vpiType, h) : NULL;
    return s != NULL && (strcmp(s, a) == 0 || strcmp(s, b) == 0) ? 1 : 0;
}

static PLI_INT32 kinds_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle bit, b6bit;
    PLI_INT32 index[2];
    s_vpi_value v;

    (void)user_data;
    var("sr", GROUP);
    v.format = vpiRealVal;
    vpi_get_value(find("sr"), &v);
    vpi_printf("sr: value %.2f\n", v.value.real);
    var("e3", SIZE | GROUP);
    var("e1", SIZE);
    var("ei", SIZE);
    var("s", SIZE | GROUP);
    var("ch", GROUP);
    var("c", GROUP);
    var("vi", GROUP);
    var("l1", SIZE);
    var("b1", SIZE);
    var("l5", SIZE);
    var("b6", SIZE);
    bit = first_bit(find("l5"));
    flags("a bit of l5", bit, SIZE);
    var("ig", SIZE);
    var("tm", SIZE);
    var("sh", SIZE);
    var("i32", SIZE);
    var("lg", SIZE);
    var("by", SIZE);
    var("re", 0);
    var("ps", SIZE);
    var("pu", SIZE);
    var("us", SIZE);
    var("uu", SIZE);
    var("as1", SIZE);
    var("av4", SIZE);
    var("ar", SIZE);

    membership("av4", find("av4"));
    membership("av4[1]", vpi_handle_by_index(find("av4"), 1));
    membership("m2d", find("m2d"));
    index[0] = 1;
    index[1] = 2;
    membership("m2d[1][2]", vpi_handle_by_multi_index(find("m2d"), 2, index));
    membership("b6", find("b6"));
    membership("l5", find("l5"));

    b6bit = first_bit(find("b6"));
    vpi_printf("vpiLogicVar is vpiReg %d, vpiVarBit is vpiRegBit %d, vpiArrayVar is vpiRegArray %d\n",
               vpiLogicVar == vpiReg, vpiVarBit == vpiRegBit, vpiArrayVar == vpiRegArray);
    vpi_printf("type names: l5 %d, a bit of l5 %d, av4 %d; a bit of the bit var b6 is a var bit %d\n",
               one_of(find("l5"), "vpiLogicVar", "vpiReg"), one_of(bit, "vpiVarBit", "vpiRegBit"),
               one_of(find("av4"), "vpiArrayVar", "vpiRegArray"),
               b6bit != NULL && vpi_get(vpiType, b6bit) == vpiVarBit ? 1 : 0);
    return 0;
}

static PLI_INT32 string_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    var("s", SIZE);
    return 0;
}

static void add(const char *name, PLI_INT32 (*calltf)(PLI_BYTE8 *))
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)name;
    d.calltf = calltf;
    vpi_register_systf(&d);
}

static void register_all(void)
{
    add("$vt_kinds", kinds_calltf);
    add("$vt_string", string_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
