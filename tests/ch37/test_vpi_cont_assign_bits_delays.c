/* VPI application of test_vpi_cont_assign_bits_delays (IEEE 1800-2023 37.47,
 * 37.3.4). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_cont_assign_bits_delays"
#define MAX 8

/* The changes recorded by the callbacks: one list for the assignment (user
 * data "a") and one for the bit (user data "b"). */
static char changes[2][MAX][24];
static int n_changes[2];

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static PLI_INT32 on_change(p_cb_data cb)
{
    int which = cb->user_data && cb->user_data[0] == 'b';
    if (n_changes[which] < MAX)
        snprintf(changes[which][n_changes[which]++], sizeof changes[0][0], "%u:%s",
                 (unsigned)cb->time->low,
                 cb->value && cb->value->value.str ? cb->value->value.str : "(null)");
    return 0;
}

static void watch(vpiHandle obj, const char *which)
{
    static s_vpi_time t;
    static s_vpi_value v;
    s_cb_data cb;
    t.type = vpiSimTime;
    v.format = vpiBinStrVal;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbValueChange;
    cb.cb_rtn = on_change;
    cb.obj = obj;
    cb.time = &t;
    cb.value = &v;
    cb.user_data = (PLI_BYTE8 *)which;
    if (vpi_register_cb(&cb) == NULL)
        vpi_printf("callback on the %s not registered\n", which[0] == 'a' ? "assignment" : "bit");
}

/* The continuous assignment whose left-hand side is the named net. */
static vpiHandle assignment_to(const char *name)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL), it, ca, found = NULL;
    it = mod ? vpi_iterate(vpiContAssign, mod) : NULL;
    while (it && (ca = vpi_scan(it)) != NULL) {
        vpiHandle lhs = vpi_handle(vpiLhs, ca);
        PLI_BYTE8 *s = lhs ? vpi_get_str(vpiName, lhs) : NULL;
        if (s && strcmp(s, name) == 0)
            found = ca;
    }
    return found;
}

static PLI_INT32 setup_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle ca = assignment_to("cv"), it, bit, bit1 = NULL;
    char lines[MAX][96];
    s_vpi_value v;
    int n = 0, i;

    (void)user_data;
    if (ca == NULL) {
        vpi_printf("the assignment to cv was not found\n");
        return 0;
    }
    it = vpi_iterate(vpiBit, ca);
    while (it && (bit = vpi_scan(it)) != NULL) {
        int offset = (int)vpi_get(vpiOffset, bit);
        if (offset == 1)
            bit1 = bit;
        if (n == MAX)
            continue;
        v.format = vpiBinStrVal;
        vpi_get_value(bit, &v);
        snprintf(lines[n++], sizeof lines[0], "offset %d: cont assign bit %d, size %d,"
                 " parent is the assignment %d, value %s", offset,
                 vpi_get(vpiType, bit) == vpiContAssignBit, (int)vpi_get(vpiSize, bit),
                 (int)vpi_compare_objects(vpi_handle(vpiParent, bit), ca),
                 v.value.str ? v.value.str : "(null)");
    }
    qsort(lines, n, sizeof lines[0], by_text);
    vpi_printf("bits of the assignment to cv: %d\n", n);
    for (i = 0; i < n; i++)
        vpi_printf("  %s\n", lines[i]);
    watch(ca, "a");
    if (bit1)
        watch(bit1, "b");
    return 0;
}

static void print_changes(const char *label, int which)
{
    int i;
    vpi_printf("changes of %s:", label);
    for (i = 0; i < n_changes[which]; i++)
        vpi_printf(" %s", changes[which][i]);
    vpi_printf("\n");
}

static int by_int(const void *a, const void *b)
{
    int x = *(const int *)a, y = *(const int *)b;
    return (x > y) - (x < y);
}

static void delay_expr(const char *name)
{
    char full[96];
    vpiHandle net, d, it, op;
    s_vpi_value v;
    int vals[MAX], n = 0, i;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    net = vpi_handle_by_name(full, NULL);
    d = net ? vpi_handle(vpiDelay, net) : NULL;
    if (d == NULL) {
        vpi_printf("vpiDelay of %s: NULL\n", name);
        return;
    }
    if (vpi_get(vpiType, d) == vpiOperation) {
        it = vpi_iterate(vpiOperand, d);
        while (it && (op = vpi_scan(it)) != NULL) {
            v.format = vpiIntVal;
            vpi_get_value(op, &v);
            if (n < MAX)
                vals[n++] = (int)v.value.integer;
        }
        qsort(vals, n, sizeof vals[0], by_int);
        vpi_printf("vpiDelay of %s: operation, list %d, operands:", name,
                   vpi_get(vpiOpType, d) == vpiListOp);
        for (i = 0; i < n; i++)
            vpi_printf(" %d", vals[i]);
        vpi_printf("\n");
    } else {
        v.format = vpiIntVal;
        vpi_get_value(d, &v);
        vpi_printf("vpiDelay of %s: value %d\n", name, (int)v.value.integer);
    }
}

/* The rise, fall and turn-off delays of the bufif1, in simulation time
 * units, which are 1 ns in this design. */
static void gate_delays(void)
{
    vpiHandle gb = vpi_handle_by_name((PLI_BYTE8 *)TOP ".gb", NULL);
    s_vpi_time t[3];
    s_vpi_delay d;
    int i;
    if (gb == NULL) {
        vpi_printf("gb not found\n");
        return;
    }
    memset(t, 0, sizeof t);
    memset(&d, 0, sizeof d);
    d.da = t;
    d.no_of_delays = 3;
    d.time_type = vpiSimTime;
    vpi_get_delays(gb, &d);
    vpi_printf("delays of gb:");
    for (i = 0; i < 3; i++)
        vpi_printf(" %u", (unsigned)t[i].low);
    vpi_printf("\n");
}

static PLI_INT32 report_calltf(PLI_BYTE8 *user_data)
{
    (void)user_data;
    print_changes("the assignment", 0);
    print_changes("its bit of offset 1", 1);
    delay_expr("n2");
    delay_expr("n1");
    gate_delays();
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
    add("$vt_setup", setup_calltf);
    add("$vt_report", report_calltf);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
