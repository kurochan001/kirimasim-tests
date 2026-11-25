#include <stddef.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#define TOP "test_vpi_legacy_real_array_root_types"
#define SPELL(token) #token
#define ABI_NAME(token) SPELL(token)

static int kind(vpiHandle item, PLI_INT32 type)
{
    return item != NULL && vpi_get(vpiType, item) == type;
}

static double real_value(vpiHandle item)
{
    s_vpi_value value = {0};
    value.format = vpiRealVal;
    if (item != NULL)
        vpi_get_value(item, &value);
    return value.value.real;
}

static PLI_INT32 check_roots(p_cb_data unused)
{
    vpiHandle array = vpi_handle_by_name((PLI_BYTE8 *)TOP ".measurements", NULL);
    vpiHandle scalar = vpi_handle_by_name((PLI_BYTE8 *)TOP ".calibration", NULL);
    vpiHandle int_array = vpi_handle_by_name((PLI_BYTE8 *)TOP ".samples", NULL);
    vpiHandle time_array = vpi_handle_by_name((PLI_BYTE8 *)TOP ".ticks", NULL);
    vpiHandle high = array != NULL ? vpi_handle_by_index(array, 4) : NULL;
    vpiHandle low = array != NULL ? vpi_handle_by_index(array, 3) : NULL;

    (void)unused;
    vpi_printf("abi=%s\n", ABI_NAME(vpi_get));
    vpi_printf("real_view root=%d root_real=%d root_array=%d scalar_real=%d high_real=%d low_real=%d\n",
               array != NULL, kind(array, vpiRealVar), kind(array, vpiArrayVar),
               kind(scalar, vpiRealVar), kind(high, vpiRealVar), kind(low, vpiRealVar));
    vpi_printf("other_views int_var=%d int_array=%d time_var=%d time_array=%d\n",
               kind(int_array, vpiIntegerVar), kind(int_array, vpiArrayVar),
               kind(time_array, vpiTimeVar), kind(time_array, vpiArrayVar));
    vpi_printf("vpi=%0.2f,%0.2f,%0.2f\n", real_value(scalar), real_value(high), real_value(low));
    return 0;
}

static PLI_INT32 schedule_check(p_cb_data unused)
{
    static s_vpi_time at_one = {vpiSimTime, 0, 1, 0.0};
    s_cb_data cb = {0};
    (void)unused;
    cb.reason = cbReadOnlySynch;
    cb.cb_rtn = check_roots;
    cb.time = &at_one;
    vpi_register_cb(&cb);
}

static void register_start(void)
{
    s_cb_data cb = {0};
    cb.reason = cbStartOfSimulation;
    cb.cb_rtn = schedule_check;
    vpi_register_cb(&cb);
}

void (*vlog_startup_routines[])(void) = {register_start, NULL};
