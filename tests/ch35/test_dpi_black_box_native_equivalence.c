/* C side of test_dpi_black_box_native_equivalence (IEEE 1800-2023 35.2, 35.3). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int stored;

int c_poly(int x)
{
    return 3 * x + 1;
}

void c_put(int x)
{
    stored = x;
}

int c_get(void)
{
    return stored;
}

#ifdef __cplusplus
}
#endif
