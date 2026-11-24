#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static s_vpi_vecval caller_words[2];
static PLI_BYTE8 caller_text[16];

static int queue(vpiHandle object, s_vpi_value *value, PLI_UINT32 ticks)
{
    s_vpi_time delay = {0};
    delay.type = vpiSimTime;
    delay.low = ticks;
    vpiHandle handle = vpi_put_value(object, value, &delay, vpiTransportDelay | vpiReturnEvent);
    int error = vpi_chk_error(NULL);
    return handle != NULL && error == 0;
}

static PLI_INT32 observe(PLI_BYTE8 *client_data)
{
    (void)client_data;
    vpiHandle vector = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_transport_value_copies_caller_vector_and_string_storage.vector_value",
        NULL);
    vpiHandle text = vpi_handle_by_name(
        (PLI_BYTE8 *)"test_vpi_transport_value_copies_caller_vector_and_string_storage.text_value",
        NULL);
    if (vector == NULL || text == NULL) {
        vpi_printf("missing write target\n");
        return 0;
    }
    s_vpi_value vector_argument = {0};
    s_vpi_value text_argument = {0};
    vector_argument.format = vpiVectorVal;
    vector_argument.value.vector = caller_words;
    text_argument.format = vpiStringVal;
    text_argument.value.str = caller_text;

    caller_words[0].aval = 0xbcdef123u;
    caller_words[0].bval = 0x0000f000u;
    caller_words[1].aval = 0x1au;
    strcpy((char *)caller_text, "first");
    int first_vector = queue(vector, &vector_argument, 2);
    int first_text = queue(text, &text_argument, 2);

    caller_words[0].aval = 0x23008967u;
    caller_words[0].bval = 0x00ff0000u;
    caller_words[1].aval = 0xfau;
    strcpy((char *)caller_text, "second");
    int second_vector = queue(vector, &vector_argument, 4);
    int second_text = queue(text, &text_argument, 4);

    memset(caller_words, 0, sizeof caller_words);
    strcpy((char *)caller_text, "reused");
    vpi_printf("queued vector=%d%d string=%d%d\n",
               first_vector, second_vector, first_text, second_text);
    return 0;
}

static void register_observation(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_schedule_values";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_observation, NULL};

#ifdef __cplusplus
}
#endif
