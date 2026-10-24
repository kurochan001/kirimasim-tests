/* C side of test_equality_class_interface_chandle_handles (IEEE 1800-2023
 * 11.4.5): returns the addresses of two different static cells, so that
 * SystemVerilog gets equal and different non-null chandles. */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int cells[2];

void *vt_cell_ptr(int which)
{
    return &cells[which & 1];
}

#ifdef __cplusplus
}
#endif
