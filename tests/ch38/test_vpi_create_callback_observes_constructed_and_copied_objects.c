/* Observe completed class construction and shallow copy through VPI. */
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_create_callback_observes_constructed_and_copied_objects"

static vpiHandle registered_type;
static PLI_INT64 first_id;
static int callbacks;
static int different_objects;

static int member_value(vpiHandle object, const char *name)
{
    vpiHandle members = vpi_iterate(vpiVariables, object);
    vpiHandle member;
    int result = -1;
    while (members && (member = vpi_scan(members))) {
        const char *member_name = vpi_get_str(vpiName, member);
        if (member_name && strcmp(member_name, name) == 0) {
            s_vpi_value value = {.format = vpiIntVal};
            vpi_get_value(member, &value);
            result = (int)value.value.integer;
        }
    }
    return result;
}

static PLI_INT32 on_created(p_cb_data data)
{
    if (!data->obj) {
        vpi_printf("creation without an object handle\n");
        return 0;
    }
    vpiHandle received_type = vpi_handle(vpiClassTypespec, data->obj);
    PLI_INT64 id = vpi_get64(vpiObjId, data->obj);
    int type_matches = vpi_get(vpiType, data->obj) == vpiClassObj &&
        received_type && vpi_compare_objects(received_type, registered_type);
    ++callbacks;
    if (callbacks == 1)
        first_id = id;
    else if (callbacks == 2)
        different_objects = first_id != 0 && id != 0 && first_id != id;
    vpi_printf("create %d type=%d token=%d derived=%d\n",
               callbacks, type_matches,
               member_value(data->obj, "token"), member_value(data->obj, "derived"));
    return 0;
}

static PLI_INT32 setup(PLI_BYTE8 *unused)
{
    (void)unused;
    static s_vpi_time no_time = {.type = vpiSuppressTime};
    vpiHandle variable = vpi_handle_by_name(TOP ".original", NULL);
    registered_type = variable ? vpi_handle(vpiClassTypespec, variable) : NULL;
    s_cb_data callback = {
        .reason = cbCreateObj,
        .cb_rtn = on_created,
        .obj = registered_type,
        .time = &no_time,
    };
    if (!registered_type || !vpi_register_cb(&callback))
        vpi_printf("could not register class creation callback\n");
    return 0;
}

static PLI_INT32 report(PLI_BYTE8 *unused)
{
    (void)unused;
    vpi_printf("total=%d different-objects=%d\n", callbacks, different_objects);
    return 0;
}

static void register_tests(void)
{
    s_vpi_systf_data setup_task = {.type = vpiSysTask, .tfname = "$vt_create_setup", .calltf = setup};
    s_vpi_systf_data report_task = {.type = vpiSysTask, .tfname = "$vt_create_report", .calltf = report};
    vpi_register_systf(&setup_task);
    vpi_register_systf(&report_task);
}

void (*vlog_startup_routines[])(void) = {register_tests, NULL};
