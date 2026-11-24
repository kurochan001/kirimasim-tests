#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle secondary;

static void print_words(const char *label, const s_vpi_vecval *words)
{
    if (words == NULL) {
        vpi_printf("%s has no vector\n", label);
        return;
    }
    vpi_printf("%s %02x/%02x_%08x/%08x\n", label,
               (unsigned)words[1].aval & 0xff, (unsigned)words[1].bval & 0xff,
               (unsigned)words[0].aval, (unsigned)words[0].bval);
}

static PLI_INT32 changed(p_cb_data callback)
{
    s_vpi_value probe = {0};
    if (callback->value == NULL || callback->value->format != vpiVectorVal) {
        vpi_printf("callback missing vector payload\n");
        return 0;
    }
    const s_vpi_vecval *saved = callback->value->value.vector;
    print_words("before get", saved);
    probe.format = vpiVectorVal;
    vpi_get_value(secondary, &probe);
    print_words("nested get", probe.value.vector);
    print_words("after get", saved);
    return 0;
}

static PLI_INT32 observe(PLI_BYTE8 *client_data)
{
    (void)client_data;
    static s_vpi_time when = {0};
    static s_vpi_value format = {0};
    s_cb_data callback = {0};
    vpiHandle watched = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_vector_callback_storage_survives_get_value_until_return.watched",
        NULL);
    secondary = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_vector_callback_storage_survives_get_value_until_return.secondary",
        NULL);
    if (watched == NULL || secondary == NULL) {
        vpi_printf("missing callback target\n");
        return 0;
    }
    when.type = vpiSuppressTime;
    format.format = vpiVectorVal;
    callback.reason = cbValueChange;
    callback.cb_rtn = changed;
    callback.obj = watched;
    callback.time = &when;
    callback.value = &format;
    vpi_printf("registered=%d\n", vpi_register_cb(&callback) != NULL);
    return 0;
}

static void register_observation(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_watch_vector";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
