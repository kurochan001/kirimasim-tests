/* VPI application of test_vpi_put_value_formats (IEEE 1800-2023 38.34). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_put_value_formats"

static vpiHandle by_name(const char *name)
{
    char full[96];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static void put_string(const char *name, const char *text, PLI_INT32 format)
{
    s_vpi_value value;
    s_vpi_time delay;

    memset(&value, 0, sizeof value);
    memset(&delay, 0, sizeof delay);
    delay.type = vpiSimTime;
    value.format = format;
    value.value.str = (PLI_BYTE8 *)text;
    vpi_put_value(by_name(name), &value, &delay, vpiNoDelay);
}

static void put_scalar(const char *name, PLI_INT32 scalar)
{
    s_vpi_value value;

    memset(&value, 0, sizeof value);
    value.format = vpiScalarVal;
    value.value.scalar = scalar;
    vpi_put_value(by_name(name), &value, NULL, vpiNoDelay);
}

static void put_int(const char *name, PLI_INT32 number)
{
    s_vpi_value value;

    memset(&value, 0, sizeof value);
    value.format = vpiIntVal;
    value.value.integer = number;
    vpi_put_value(by_name(name), &value, NULL, vpiNoDelay);
}

static void put_real(const char *name, double number)
{
    s_vpi_value value;

    memset(&value, 0, sizeof value);
    value.format = vpiRealVal;
    value.value.real = number;
    vpi_put_value(by_name(name), &value, NULL, vpiNoDelay);
}

static PLI_INT32 put_calltf(PLI_BYTE8 *user_data)
{
    s_vpi_vecval words[2];
    s_vpi_value value;

    (void)user_data;
    put_string("b", "1011", vpiBinStrVal);
    put_string("o", "17", vpiOctStrVal);
    put_string("d", "42", vpiDecStrVal);
    put_string("h", "3f", vpiHexStrVal);
    put_scalar("sc", vpi1);
    put_int("i", -5);
    put_real("r", 2.5);
    put_string("st", "AB", vpiStringVal);

    memset(words, 0, sizeof words);
    words[0].aval = 0x89abcdefu;
    words[1].aval = 0x12u;
    memset(&value, 0, sizeof value);
    value.format = vpiVectorVal;
    value.value.vector = words;
    vpi_put_value(by_name("vec"), &value, NULL, vpiNoDelay);

    vpi_printf("errors %d\n", vpi_chk_error(NULL) != 0 ? 1 : 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_put";
    d.calltf = put_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
