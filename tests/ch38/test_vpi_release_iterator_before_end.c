#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 check_iterators(p_cb_data data)
{
    vpiHandle top, cursor, child;
    int first, released, count = 0;
    (void)data;

    top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_release_iterator_before_end", NULL);
    if (top == NULL) {
        vpi_printf("cannot find top\n");
        return 0;
    }
    cursor = vpi_iterate(vpiModule, top);
    child = cursor != NULL ? vpi_scan(cursor) : NULL;
    first = child != NULL;
    released = first && vpi_release_handle(cursor) == 1;
    cursor = vpi_iterate(vpiModule, top);
    if (cursor != NULL) {
        while (vpi_scan(cursor) != NULL)
            count++;
    }
    vpi_printf("first=%d released=%d fresh_count=%d\n", first, released, count);
    return 0;
}

static void register_callback(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = check_iterators;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_callback, NULL};

#ifdef __cplusplus
}
#endif
