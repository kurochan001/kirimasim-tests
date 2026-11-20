/* IEEE 1800-2023 37.29 B007, 37.15 details 1-3: reference identity. */
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_interface_expression_port_refs_and_null"

static int same(vpiHandle a, vpiHandle b)
{
    return a && b && vpi_compare_objects(a, b) ? 1 : 0;
}

static vpiHandle named(PLI_INT32 type, vpiHandle scope, const char *name)
{
    vpiHandle it = scope ? vpi_iterate(type, scope) : NULL, h, found = NULL;
    while (it && (h = vpi_scan(it))) {
        const char *s = vpi_get_str(vpiName, h);
        if (s && strcmp(s, name) == 0)
            found = h;
    }
    return found;
}

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static PLI_INT32 calltf(PLI_BYTE8 *user_data)
{
    vpiHandle child = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u", NULL);
    vpiHandle left = vpi_handle_by_name((PLI_BYTE8 *)TOP ".left", NULL);
    vpiHandle right = vpi_handle_by_name((PLI_BYTE8 *)TOP ".right", NULL);
    vpiHandle mp = named(vpiModport, right, "mp");
    vpiHandle task = named(vpiTask, child, "sets");
    vpiHandle body = task ? vpi_handle(vpiStmt, task) : NULL;
    vpiHandle it = body ? vpi_iterate(vpiStmt, body) : NULL, stmt;
    char lines[3][240];
    int n = 0, total = 0, i;
    (void)user_data;
    while (it && (stmt = vpi_scan(it))) {
        vpiHandle lhs, rhs, actual;
        const char *name;
        char label[16];
        ++total;
        if (n == 3 || vpi_get(vpiType, stmt) != vpiAssignment)
            continue;
        lhs = vpi_handle(vpiLhs, stmt);
        rhs = vpi_handle(vpiRhs, stmt);
        name = lhs ? vpi_get_str(vpiName, lhs) : NULL;
        snprintf(label, sizeof label, "%s", name ? name : "missing");
        if (strcmp(label, "vi") == 0 || strcmp(label, "vm") == 0) {
            int is_mp = strcmp(label, "vm") == 0;
            vpiHandle port = named(vpiPort, child, is_mp ? "m" : "s");
            vpiHandle low = port ? vpi_handle(vpiLowConn, port) : NULL;
            actual = rhs ? vpi_handle(vpiActual, rhs) : NULL;
            snprintf(lines[n++], sizeof lines[0],
                     "%s: lhs virtual interface var %d, rhs ref obj %d, local port %d, "
                     "actual type %d, correct actual %d, wrong interface %d",
                     label, lhs && vpi_get(vpiType, lhs) == vpiVirtualInterfaceVar,
                     rhs && vpi_get(vpiType, rhs) == vpiRefObj, same(rhs, low),
                     actual && vpi_get(vpiType, actual) == (is_mp ? vpiModport : vpiInterface),
                     same(actual, is_mp ? mp : left), same(actual, is_mp ? left : right));
        } else if (strcmp(label, "vn") == 0) {
            snprintf(lines[n++], sizeof lines[0],
                     "vn: lhs virtual interface var %d, rhs constant %d, null constant %d",
                     lhs && vpi_get(vpiType, lhs) == vpiVirtualInterfaceVar,
                     rhs && vpi_get(vpiType, rhs) == vpiConstant,
                     rhs && vpi_get(vpiConstType, rhs) == vpiNullConst);
        }
    }
    qsort(lines, (size_t)n, sizeof lines[0], by_text);
    vpi_printf((PLI_BYTE8 *)"statements %d, observed expressions %d\n", total, n);
    for (i = 0; i < n; ++i)
        vpi_printf((PLI_BYTE8 *)"%s\n", lines[i]);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_interface_refs";
    d.calltf = calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
