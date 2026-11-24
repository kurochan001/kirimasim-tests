/* Verify that whole objects excluded from cbValueChange do not deliver callbacks. */
#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_value_change_excludes_whole_dynamic_containers_and_class_objects"

enum watch_slot {
    DYNAMIC_ARRAY, STRING_VAR, QUEUE_VAR, ASSOCIATIVE_ARRAY, CLASS_OBJECT,
    SCALAR_VAR, CLASS_REFERENCE, SLOT_COUNT
};

static int calls[SLOT_COUNT];
static s_vpi_time no_time = {.type = vpiSuppressTime};
static s_vpi_value no_value = {.format = vpiSuppressVal};

static PLI_INT32 update_count(p_cb_data data)
{
    int *count = (int *)data->user_data;
    ++*count;
    return 0;
}

static void watch(vpiHandle object, enum watch_slot slot, const char *label)
{
    if (!object) {
        vpi_printf("missing VPI handle for %s\n", label);
        return;
    }
    s_cb_data cb = {
        .reason = cbValueChange,
        .cb_rtn = update_count,
        .obj = object,
        .time = &no_time,
        .value = &no_value,
        .user_data = (PLI_BYTE8 *)&calls[slot],
    };
    vpiHandle registered = vpi_register_cb(&cb);
    if ((slot == SCALAR_VAR || slot == CLASS_REFERENCE) && !registered)
        vpi_printf("could not register the control callback for %s\n", label);
}

static PLI_INT32 setup(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle reference = vpi_handle_by_name(TOP ".reference_handle", NULL);
    vpiHandle object = reference ? vpi_handle(vpiClassObj, reference) : NULL;
    watch(vpi_handle_by_name(TOP ".dynamic_values", NULL), DYNAMIC_ARRAY, "dynamic array");
    watch(vpi_handle_by_name(TOP ".text", NULL), STRING_VAR, "string");
    watch(vpi_handle_by_name(TOP ".queue_values", NULL), QUEUE_VAR, "queue");
    watch(vpi_handle_by_name(TOP ".associative_values", NULL), ASSOCIATIVE_ARRAY, "associative array");
    watch(object, CLASS_OBJECT, "class object");
    watch(vpi_handle_by_name(TOP ".scalar", NULL), SCALAR_VAR, "scalar control");
    watch(reference, CLASS_REFERENCE, "class reference control");
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("whole dynamic=%d string=%d queue=%d associative=%d object=%d scalar=%d reference=%d\n",
               calls[DYNAMIC_ARRAY], calls[STRING_VAR], calls[QUEUE_VAR], calls[ASSOCIATIVE_ARRAY],
               calls[CLASS_OBJECT], calls[SCALAR_VAR], calls[CLASS_REFERENCE]);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data setup_task = {
        .type = vpiSysTask, .tfname = "$vt_value_change_watch_exclusions", .calltf = setup,
    };
    s_vpi_systf_data report_task = {
        .type = vpiSysTask, .tfname = "$vt_value_change_report_exclusions", .calltf = report,
    };
    vpi_register_systf(&setup_task);
    vpi_register_systf(&report_task);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
