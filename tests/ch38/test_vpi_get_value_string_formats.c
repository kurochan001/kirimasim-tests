/* VPI application of test_vpi_get_value_string_formats (IEEE 1800-2023 38.15). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_string_formats."

static vpiHandle object(const char *name)
{
    char full[96];
    strcpy(full, TOP);
    strcat(full, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

/* Prints the string of format f; the string is copied before the next call. */
static void show_str(const char *name, PLI_INT32 f, const char *label)
{
    vpiHandle h = object(name);
    s_vpi_value v;
    char text[64];

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    v.format = f;
    vpi_get_value(h, &v);
    strncpy(text, v.value.str ? v.value.str : "(NULL)", sizeof text - 1);
    text[sizeof text - 1] = '\0';
    vpi_printf((PLI_BYTE8 *)"%s %s: %s\n", name, label, text);
}

static void show_int(const char *name)
{
    vpiHandle h = object(name);
    s_vpi_value v;

    if (h == NULL)
        return;
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    vpi_printf((PLI_BYTE8 *)"%s vpiIntVal: %d\n", name, (int)v.value.integer);
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    static const char *const names[] = {"h1", "h2", "o1", "o2", "all_x", "all_z"};
    int k;

    (void)cb;
    for (k = 0; k < 6; k++) {
        show_str(names[k], vpiBinStrVal, "vpiBinStrVal");
        if (k != 2 && k != 3)
            show_str(names[k], vpiHexStrVal, "vpiHexStrVal");
        if (k >= 2)
            show_str(names[k], vpiOctStrVal, "vpiOctStrVal");
        show_int(names[k]);
    }
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time delay;
    s_cb_data cb;

    (void)data;
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = on_delay;
    cb.time = &delay;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
