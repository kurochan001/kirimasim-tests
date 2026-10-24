/* VPI application of test_vpi_reg_array_scope_index (IEEE 1800-2023 37.20). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_reg_array_scope_index"

/* vpi_get_str reuses its buffer (38.11), so every string is copied. */
static char *copy(PLI_BYTE8 *s)
{
    const char *t = s ? s : "(null)";
    char *c = (char *)malloc(strlen(t) + 1);
    strcpy(c, t);
    return c;
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b) ? 1 : 0;
}

static void describe(const char *label, vpiHandle a, vpiHandle scope, vpiHandle top)
{
    vpiHandle s = vpi_handle(vpiScope, a), m = vpi_handle(vpiModule, a);
    vpi_printf("%s: reg array %d, scope %s, scope is the module %d, scope is the expected "
               "one %d, module is the module %d, is memory %d\n",
               label, vpi_get(vpiType, a) == vpiRegArray ? 1 : 0,
               s ? copy(vpi_get_str(vpiName, s)) : "NULL", same(s, top), same(s, scope),
               same(m, top), (int)vpi_get(vpiIsMemory, a));
}

static void element(const char *label, vpiHandle e, const char *name)
{
    vpiHandle by_name = vpi_handle_by_name((PLI_BYTE8 *)name, NULL);
    if (e == NULL) {
        vpi_printf("%s: NULL\n", label);
        return;
    }
    vpi_printf("%s: %s, same as by name %d, value %d\n", label, copy(vpi_get_str(vpiName, e)),
               same(e, by_name), int_value(e));
}

static PLI_INT32 reg_array_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle blk = vpi_handle_by_name((PLI_BYTE8 *)TOP ".blk", NULL);
    vpiHandle mem = vpi_handle_by_name((PLI_BYTE8 *)TOP ".mem", NULL);
    vpiHandle grid = vpi_handle_by_name((PLI_BYTE8 *)TOP ".grid", NULL);
    vpiHandle lm = vpi_handle_by_name((PLI_BYTE8 *)TOP ".blk.lm", NULL);
    PLI_INT32 two[2], one[1];

    (void)user_data;
    if (top == NULL || blk == NULL || mem == NULL || grid == NULL || lm == NULL) {
        vpi_printf("not found\n");
        return 0;
    }
    describe("mem", mem, top, top);
    describe("grid", grid, top, top);
    describe("blk.lm", lm, blk, top);

    element("mem by index 2", vpi_handle_by_index(mem, 2), TOP ".mem[2]");
    two[0] = 2;
    two[1] = 4;
    element("grid by multi-index 2, 4", vpi_handle_by_multi_index(grid, 2, two), TOP ".grid[2][4]");
    two[0] = 1;
    two[1] = 5;
    element("grid by multi-index 1, 5", vpi_handle_by_multi_index(grid, 2, two), TOP ".grid[1][5]");
    one[0] = 3;
    element("mem by multi-index 3", vpi_handle_by_multi_index(mem, 1, one), TOP ".mem[3]");
    element("blk.lm by index 1", vpi_handle_by_index(lm, 1), TOP ".blk.lm[1]");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_reg_array";
    d.calltf = reg_array_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
