/* C side of test_chandle_null_boolean_and_uses (IEEE 1800-2023 6.14). */
#include <stddef.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int cells[2] = {20, 21};

void *chu_cell(int k)
{
    return (k == 0 || k == 1) ? (void *)&cells[k] : NULL;
}

int chu_is_zero(void *h)
{
    return h == NULL;
}

int chu_value(void *h)
{
    return h != NULL ? *(int *)h : -1;
}

#ifdef __cplusplus
}
#endif
