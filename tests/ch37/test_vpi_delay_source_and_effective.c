/* VPI application of test_vpi_delay_source_and_effective (IEEE 1800-2023 37.3.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_delay_source_and_effective"

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static int int_value(vpiHandle h)
{
    s_vpi_value v;
    v.format = vpiIntVal;
    v.value.integer = -1;
    if (h != NULL)
        vpi_get_value(h, &v);
    return (int)v.value.integer;
}

static int by_value(const void *x, const void *y)
{
    int a = *(const int *)x, b = *(const int *)y;
    return (a > b) - (a < b);
}

/* Prints the source delay that vpiDelay gives for the primitive `name`. */
static void source_delay(const char *name, const char *when)
{
    vpiHandle g = find(name), d = g != NULL ? vpi_handle(vpiDelay, g) : NULL, it, op;
    int is_op = d != NULL && vpi_get(vpiType, d) == vpiOperation;
    int values[4], n = 0, i;

    vpi_printf((PLI_BYTE8 *)"%s source delay%s: ", name, when);
    if (d == NULL) {
        vpi_printf((PLI_BYTE8 *)"NULL\n");
    } else if (!is_op) {
        vpi_printf((PLI_BYTE8 *)"expression of value %d\n", int_value(d));
    } else {
        vpi_printf((PLI_BYTE8 *)"operation, list %d, operands (sorted)",
                   vpi_get(vpiOpType, d) == vpiListOp);
        it = vpi_iterate(vpiOperand, d);
        while (it != NULL && (op = vpi_scan(it)) != NULL && n < 4)
            values[n++] = int_value(op);
        qsort(values, (size_t)n, sizeof values[0], by_value);
        for (i = 0; i < n; i++)
            vpi_printf((PLI_BYTE8 *)" %d", values[i]);
        vpi_printf((PLI_BYTE8 *)"\n");
    }
}

/* Prints the rise and fall delays that vpi_get_delays gives for g1. */
static void used_delays(const char *when)
{
    s_vpi_time t[2];
    s_vpi_delay d;

    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    d.da = t;
    d.no_of_delays = 2;
    d.time_type = vpiSimTime;
    if (find("g1") != NULL)
        vpi_get_delays(find("g1"), &d);
    vpi_printf((PLI_BYTE8 *)"g1 delays in use %s: %u %u\n", when, (unsigned)t[0].low,
               (unsigned)t[1].low);
}

static PLI_INT32 start_of_simulation(p_cb_data cb)
{
    s_vpi_time t[2];
    s_vpi_delay d;
    s_vpi_value v;
    vpiHandle r = find("r");
    int i;

    (void)cb;
    source_delay("g1", "");
    source_delay("g2", "");
    used_delays("before vpi_put_delays");
    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    for (i = 0; i < 2; i++) {
        t[i].type = vpiSimTime;
        t[i].low = 7;
    }
    d.da = t;
    d.no_of_delays = 2;
    d.time_type = vpiSimTime;
    if (find("g1") != NULL)
        vpi_put_delays(find("g1"), &d);
    used_delays("after vpi_put_delays");
    source_delay("g1", " after vpi_put_delays");

    v.format = vpiIntVal;
    v.value.integer = 60;
    if (r != NULL)
        vpi_put_value(r, &v, NULL, vpiNoDelay);
    vpi_printf((PLI_BYTE8 *)"r read back after vpi_put_value: %d\n", int_value(r));
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = start_of_simulation;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
