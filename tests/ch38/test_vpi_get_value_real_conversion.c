/* VPI application of test_vpi_get_value_real_conversion (IEEE 1800-2023 38.15). */
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get_value_real_conversion."

static vpiHandle object(const char *name)
{
    char full[96];
    strcpy(full, TOP);
    strcat(full, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void as_integer(const char *name)
{
    vpiHandle h = object(name);
    s_vpi_value v;
    char dec[40];

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    v.format = vpiDecStrVal;
    v.value.str = NULL;
    vpi_get_value(h, &v);
    strncpy(dec, v.value.str ? v.value.str : "(no string)", sizeof dec - 1);
    dec[sizeof dec - 1] = '\0';
    v.format = vpiIntVal;
    vpi_get_value(h, &v);
    vpi_printf((PLI_BYTE8 *)"%s: vpiIntVal %d, vpiDecStrVal %s\n", name, (int)v.value.integer, dec);
}

static void as_string(const char *name)
{
    vpiHandle h = object(name);
    s_vpi_value v;
    const char *p;
    int digits = 0, leading = 1, exponent = 0;

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", name);
        return;
    }
    v.format = vpiStringVal;
    v.value.str = NULL;
    vpi_get_value(h, &v);
    if (v.value.str == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: vpiStringVal gives no string\n", name);
        return;
    }
    for (p = v.value.str; *p != '\0'; p++) {
        if (*p == 'e' || *p == 'E')
            exponent = 1;
        else if (*p >= '1' && *p <= '9')
            leading = 0;
        if (*p >= '0' && *p <= '9' && !leading && !exponent)
            digits++;
    }
    vpi_printf((PLI_BYTE8 *)"%s: vpiStringVal without exponent %s, at most 16 significant "
               "digits %s, reads back as %.10g\n", name, exponent ? "no" : "yes",
               digits <= 16 ? "yes" : "no", strtod(v.value.str, NULL));
}

static PLI_INT32 on_delay(p_cb_data cb)
{
    (void)cb;
    as_integer("up_half");
    as_integer("down_half");
    as_integer("below_half");
    as_integer("above_half");
    as_string("text_a");
    as_string("text_b");
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
