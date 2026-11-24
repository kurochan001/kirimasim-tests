#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static vpiHandle saved_time;

static PLI_INT32 after_vector(p_cb_data data)
{
    s_vpi_value time_value = {0};
    if (data->value == NULL || data->value->value.vector == NULL)
        return 0;
    const s_vpi_vecval *vector = data->value->value.vector;
    time_value.format = vpiTimeVal;
    vpi_get_value(saved_time, &time_value);

    int retained = vector[0].aval == 0x76543210u && vector[0].bval == 0 &&
                   vector[1].aval == 0x13572468u && vector[1].bval == 0 &&
                   vector[2].aval == 2 && vector[2].bval == 0;
    int nested = time_value.value.time != NULL &&
                 time_value.value.time->high == 0x24681357u &&
                 time_value.value.time->low == 0xfedcba98u;
    vpi_printf("callback retained=%d nested read=%d\n", retained, nested);
    return 0;
}

static vpiHandle find(vpiHandle top, const char *name)
{
    return vpi_handle_by_name((PLI_BYTE8 *)name, top);
}

static PLI_INT32 prepare(PLI_BYTE8 *unused)
{
    vpiHandle call = vpi_handle(vpiSysTfCall, NULL);
    vpiHandle scope = call != NULL ? vpi_handle(vpiScope, call) : NULL;
    (void)unused;
    if (scope == NULL)
        return 0;
    vpiHandle watched = find(scope, "watched");
    vpiHandle word = find(scope, "word"), powered = find(scope, "powered");
    saved_time = find(scope, "stamp");
    if (watched == NULL || word == NULL || powered == NULL || saved_time == NULL)
        return 0;

    s_vpi_value value = {0};
    value.format = vpiTimeVal;
    vpi_get_value(saved_time, &value);
    const s_vpi_time *time = value.value.time;
    vpi_get(vpiSize, word);
    int time_valid = time != NULL && time->high == 0x01234567u && time->low == 0x89abcdefu;

    value.format = vpiStringVal;
    vpi_get_value(word, &value);
    const PLI_BYTE8 *string = value.value.str;
    vpi_get_str(vpiName, watched);
    int string_valid = string != NULL && strcmp((const char *)string, "READ") == 0;

    value.format = vpiStrengthVal;
    vpi_get_value(powered, &value);
    const s_vpi_strengthval *strength = value.value.strength;
    vpi_get(vpiSize, word);
    int strength_valid = strength != NULL && strength->logic == vpi1 &&
                         strength->s1 == vpiWeakDrive;

    s_vpi_time new_time = {.type = vpiSimTime, .high = 0x24681357u, .low = 0xfedcba98u};
    value.format = vpiTimeVal;
    value.value.time = &new_time;
    vpi_put_value(saved_time, &value, NULL, vpiNoDelay);
    PLI_BYTE8 new_word[] = "KEEP";
    value.format = vpiStringVal;
    value.value.str = new_word;
    vpi_put_value(word, &value, NULL, vpiNoDelay);
    vpi_printf("time valid=%d string valid=%d strength valid=%d\n",
               time_valid, string_valid, strength_valid);

    s_vpi_time cb_time = {.type = vpiSimTime};
    s_vpi_value cb_value = {.format = vpiVectorVal};
    s_cb_data spec = {.reason = cbValueChange, .cb_rtn = after_vector, .obj = watched,
                      .time = &cb_time, .value = &cb_value};
    vpi_register_cb(&spec);
    return 0;
}

static void register_task(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_prepare_buffers";
    task.calltf = prepare;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_task, NULL};

#ifdef __cplusplus
}
#endif
