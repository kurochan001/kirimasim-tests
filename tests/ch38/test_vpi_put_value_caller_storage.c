/* VPI application of test_vpi_put_value_caller_storage (IEEE 1800-2023 38.34). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_caller_storage."

/* One value structure, one string buffer, one vector and one delay, which
   every put uses again, so that each put overwrites what the one before it
   passed. */
static s_vpi_value value;
static char buffer[16];
static s_vpi_vecval words[2];
static s_vpi_time delay;

static void put_later(const char *name)
{
    char full[96];
    vpiHandle h;

    strcpy(full, TOP);
    strcat(full, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s not found\n", name);
        return;
    }
    delay.type = vpiSimTime;
    delay.high = 0;
    delay.low = 4;
    vpi_put_value(h, &value, &delay, vpiInertialDelay);
}

static void put_string(const char *name, PLI_INT32 format, const char *text)
{
    strcpy(buffer, text);
    value.format = format;
    value.value.str = buffer;
    put_later(name);
}

static PLI_INT32 at_1(p_cb_data data)
{
    (void)data;
    put_string("b", vpiBinStrVal, "10x0z101");
    put_string("o", vpiOctStrVal, "7x5");
    put_string("d", vpiDecStrVal, "201");
    put_string("h", vpiHexStrVal, "be0f");
    put_string("st", vpiStringVal, "wxyz");

    value.format = vpiScalarVal;
    value.value.scalar = vpi1;
    put_later("s");

    value.format = vpiIntVal;
    value.value.integer = -12345;
    put_later("i");

    value.format = vpiRealVal;
    value.value.real = 6.125;
    put_later("r");

    words[0].aval = 0x01234567u;
    words[0].bval = 0u;
    words[1].aval = 0x8fu;
    words[1].bval = 0x0fu;
    value.format = vpiVectorVal;
    value.value.vector = words;
    put_later("vec");

    /* All the structures change before the events happen. */
    memset(buffer, '1', sizeof buffer - 1);
    memset(words, 0, sizeof words);
    value.format = vpiIntVal;
    value.value.integer = 0;
    delay.low = 8;
    return 0;
}

static PLI_INT32 on_start(p_cb_data data)
{
    static s_vpi_time one;
    s_cb_data cb;

    (void)data;
    one.type = vpiSimTime;
    one.high = 0;
    one.low = 1;
    memset(&cb, 0, sizeof cb);
    cb.reason = cbAfterDelay;
    cb.cb_rtn = at_1;
    cb.time = &one;
    vpi_register_cb(&cb);
    return 0;
}

static void register_all(void)
{
    s_cb_data cb;

    memset(&cb, 0, sizeof cb);
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = on_start;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
