#include <stddef.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

enum { MAX_CHECKS = 32 };
static vpiHandle checks[MAX_CHECKS];
static int count;
static int delivered[MAX_CHECKS];
static int width_hits;
static int setup_hits;
static int unrelated;
static int pulse;

static PLI_INT32 violation(p_cb_data data)
{
    for (int i = 0; i < count; ++i) {
        if (data->reason == cbTchkViolation && data->obj && vpi_compare_objects(checks[i], data->obj)) {
            int type = vpi_get(vpiTchkType, data->obj);
            width_hits += type == vpiWidth;
            setup_hits += type == vpiSetup;
            ++delivered[i];
            return 0;
        }
    }
    ++unrelated;
    return 0;
}

static PLI_INT32 arm(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle cell = vpi_handle_by_name("test_vector_timing_check_expansion.dut", NULL);
    vpiHandle notifier = vpi_handle_by_name("test_vector_timing_check_expansion.dut.notifier", NULL);
    vpiHandle iter = cell ? vpi_iterate(vpiTchk, cell) : NULL;
    vpiHandle item;
    int width = 0, setup = 0, shared = 0;
    while (iter && (item = vpi_scan(iter))) {
        int type = vpi_get(vpiTchkType, item);
        width += type == vpiWidth;
        setup += type == vpiSetup;
        vpiHandle linked = vpi_handle(vpiTchkNotifier, item);
        shared += notifier && linked && vpi_compare_objects(notifier, linked);
        if (count < MAX_CHECKS)
            checks[count++] = item;
    }
    s_cb_data registration = {.reason = cbTchkViolation, .cb_rtn = violation};
    vpi_printf("width=%d setup=%d shared=%d callback=%d\n", width, setup, shared,
               vpi_register_cb(&registration) != NULL);
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    int distinct = 0;
    for (int index = 0; index < count; ++index)
        distinct += delivered[index] != 0;
    vpi_printf("pulse=%d width=%d setup=%d distinct=%d unrelated=%d\n",
               pulse++, width_hits, setup_hits, distinct, unrelated);
    width_hits = setup_hits = unrelated = 0;
    memset(delivered, 0, sizeof delivered);
    return 0;
}

static void install(void)
{
    s_vpi_systf_data task = {.type = vpiSysTask, .tfname = "$arm_vector_timing", .calltf = arm};
    vpi_register_systf(&task);
    task.tfname = "$report_vector_timing";
    task.calltf = report;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {install, NULL};
