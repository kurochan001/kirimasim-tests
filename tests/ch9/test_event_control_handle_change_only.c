/* C side of test_event_control_handle_change_only (IEEE 1800-2023 9.4.2). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int slots[3];

/* A distinct, non-null address for each n in 0..2. */
void *vt_slot(int n)
{
    return &slots[n];
}

#ifdef __cplusplus
}
#endif
