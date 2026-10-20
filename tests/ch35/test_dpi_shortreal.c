/* C side of test_dpi_shortreal (IEEE 1800-2023 35.5.6, H.7.4). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

float dpi_scale(float x, float by) { return x * by; }

int dpi_is_third(float x)
{
    volatile float f = (float)(1.0 / 3.0);
    return x == f;
}

#ifdef __cplusplus
}
#endif
