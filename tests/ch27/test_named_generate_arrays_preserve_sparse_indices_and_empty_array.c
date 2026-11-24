#include <stddef.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int has_index(vpiHandle array, int index)
{
    return array != NULL && vpi_handle_by_index(array, index) != NULL;
}

static PLI_INT32 check_arrays(p_cb_data data)
{
    vpiHandle sparse, empty, cursor, scope;
    int instances = 0;
    (void)data;

    sparse = vpi_handle_by_name((PLI_BYTE8 *)"test_named_generate_arrays_preserve_sparse_indices_and_empty_array.sparse", NULL);
    empty = vpi_handle_by_name((PLI_BYTE8 *)"test_named_generate_arrays_preserve_sparse_indices_and_empty_array.empty", NULL);
    cursor = empty != NULL ? vpi_iterate(vpiGenScope, empty) : NULL;
    if (cursor != NULL) {
        while ((scope = vpi_scan(cursor)) != NULL)
            instances++;
    }
    vpi_printf("sparse: 2=%d 3=%d 5=%d 8=%d\n",
               has_index(sparse, 2), has_index(sparse, 3),
               has_index(sparse, 5), has_index(sparse, 8));
    vpi_printf("empty: array=%d instances=%d\n",
               empty != NULL && vpi_get(vpiType, empty) == vpiGenScopeArray, instances);
    return 0;
}

static void register_arrays(void)
{
    s_cb_data callback = {0};
    callback.reason = cbStartOfSimulation;
    callback.cb_rtn = check_arrays;
    vpi_register_cb(&callback);
}

void (*vlog_startup_routines[])(void) = {register_arrays, NULL};

#ifdef __cplusplus
}
#endif
