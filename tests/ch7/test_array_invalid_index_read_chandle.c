/* C side of test_array_invalid_index_read_chandle (IEEE 1800-2023 7.4.5). */
#include <stddef.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int tokens[4] = {10, 11, 12, 13};

void *c_token(int k)
{
    return (k >= 0 && k < 4) ? (void *)&tokens[k] : NULL;
}

int c_token_value(void *h)
{
    return h != NULL ? *(int *)h : -1;
}

#ifdef __cplusplus
}
#endif
