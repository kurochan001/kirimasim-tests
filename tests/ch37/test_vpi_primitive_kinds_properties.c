/* VPI application of test_vpi_primitive_kinds_properties (IEEE 1800-2023 37.35). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_primitive_kinds_properties"
#define MAX 8
#define LEN 256

static char lines[MAX][LEN];
static int n_lines;

static int by_text(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static void flush_lines(void)
{
    int i;
    qsort(lines, (size_t)n_lines, LEN, by_text);
    for (i = 0; i < n_lines; i++)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    n_lines = 0;
}

static const char *str_of(PLI_INT32 prop, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(prop, h) : NULL;
    return s != NULL ? s : "(none)";
}

static const char *kind(vpiHandle h)
{
    switch (vpi_get(vpiType, h)) {
    case vpiGate: return "gate";
    case vpiSwitch: return "switch";
    case vpiUdp: return "udp";
    default: return "other";
    }
}

static const char *prim_type(vpiHandle h)
{
    switch (vpi_get(vpiPrimType, h)) {
    case vpiAndPrim: return "and";
    case vpiNandPrim: return "nand";
    case vpiNorPrim: return "nor";
    case vpiBufPrim: return "buf";
    case vpiNmosPrim: return "nmos";
    case vpiCombPrim: return "combinational";
    case vpiSeqPrim: return "sequential";
    default: return "other";
    }
}

static const char *strength(PLI_INT32 s)
{
    switch (s) {
    case vpiSupplyDrive: return "supply";
    case vpiStrongDrive: return "strong";
    case vpiPullDrive: return "pull";
    case vpiWeakDrive: return "weak";
    case vpiHighZ: return "highz";
    default: return "other";
    }
}

/* The module instance that holds a primitive, by its full name. */
static void module_of(vpiHandle prim, char *out, size_t len)
{
    vpiHandle m = vpi_handle(vpiModule, prim);
    if (m == NULL)
        snprintf(out, len, "NULL");
    else
        snprintf(out, len, "%s%s", vpi_get(vpiType, m) == vpiModule ? "" : "(not a module) ",
                 str_of(vpiFullName, m));
}

/* One line for a primitive outside an array; with_strength says whether the
 * instantiation gives drive strengths, with_inputs whether vpiSize is shown. */
static void describe(vpiHandle h, int with_strength, int with_inputs)
{
    char name[48], full[96], mod[96], tail[96] = "", inputs[24] = "", line[LEN];

    snprintf(name, sizeof name, "%s", str_of(vpiName, h));
    snprintf(full, sizeof full, "%s", str_of(vpiFullName, h));
    module_of(h, mod, sizeof mod);
    if (with_inputs)
        snprintf(inputs, sizeof inputs, ", inputs %d", (int)vpi_get(vpiSize, h));
    if (vpi_get(vpiType, h) == vpiUdp)
        snprintf(tail + strlen(tail), sizeof tail - strlen(tail), ", definition %s",
                 str_of(vpiDefName, h));
    if (with_strength)
        snprintf(tail + strlen(tail), sizeof tail - strlen(tail), ", strengths %s0 %s1",
                 strength(vpi_get(vpiStrength0, h)), strength(vpi_get(vpiStrength1, h)));
    snprintf(line, sizeof line, "%s: %s %s, full name %s%s, module %s, array member %d %d%s",
             name, kind(h), prim_type(h), full, inputs, mod, (int)vpi_get(vpiArrayMember, h),
             (int)vpi_get(vpiArray, h), tail);
    if (n_lines < MAX)
        snprintf(lines[n_lines++], LEN, "%s", line);
}

static int listed(const char *name, const char *const *names)
{
    int i;
    for (i = 0; names[i] != NULL; i++)
        if (strcmp(name, names[i]) == 0)
            return 1;
    return 0;
}

static void primitives_of(const char *label, const char *path)
{
    static const char *const strong[] = {"g_and", "g_buf", NULL};
    char full[96];
    vpiHandle mod, it, h;
    int n = 0;

    snprintf(full, sizeof full, "%s%s", TOP, path);
    mod = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    it = mod != NULL ? vpi_iterate(vpiPrimitive, mod) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        describe(h, listed(str_of(vpiName, h), strong), vpi_get(vpiType, h) != vpiSwitch);
        n++;
    }
    vpi_printf((PLI_BYTE8 *)"primitives of %s: %d\n", label, n);
    flush_lines();
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    if (h == NULL)
        return -1;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static void gate_array(void)
{
    vpiHandle arr = vpi_handle_by_name((PLI_BYTE8 *)TOP ".arr", NULL), it, ga = NULL, h, back;
    char mod[96];
    int n_arrays = 0, n = 0;

    it = arr != NULL ? vpi_iterate(vpiPrimitiveArray, arr) : NULL;
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        n_arrays++;
        ga = h;
    }
    vpi_printf((PLI_BYTE8 *)"primitive arrays of arr: %d, %s, gate array %d\n", n_arrays,
               str_of(vpiName, ga), ga != NULL && vpi_get(vpiType, ga) == vpiGateArray);
    if (ga == NULL || n_arrays != 1)
        return;
    it = vpi_iterate(vpiPrimitive, ga);
    while (it != NULL && (h = vpi_scan(it)) != NULL) {
        back = vpi_handle(vpiPrimitiveArray, h);
        module_of(h, mod, sizeof mod);
        if (n_lines < MAX)
            snprintf(lines[n_lines++], LEN,
                     "  element with index %d: %s %s, inputs %d, module %s, array member %d %d, "
                     "its array is ga %d, strengths %s0 %s1",
                     int_value(vpi_handle(vpiIndex, h)), kind(h), prim_type(h),
                     (int)vpi_get(vpiSize, h), mod, (int)vpi_get(vpiArrayMember, h),
                     (int)vpi_get(vpiArray, h), back != NULL && vpi_compare_objects(back, ga),
                     strength(vpi_get(vpiStrength0, h)), strength(vpi_get(vpiStrength1, h)));
        n++;
    }
    vpi_printf((PLI_BYTE8 *)"elements of ga: %d\n", n);
    flush_lines();
}

static PLI_INT32 prims_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    primitives_of("the top module", "");
    primitives_of("sub", ".sub");
    gate_array();
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_prims";
    d.calltf = prims_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
