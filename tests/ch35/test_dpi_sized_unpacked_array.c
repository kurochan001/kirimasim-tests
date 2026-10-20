/* C side of test_dpi_sized_unpacked_array (IEEE 1800-2023 35.5.6, H.7.6). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int weigh(const int *a)
{
    int i, sum = 0;
    for (i = 0; i < 4; i++)
        sum += a[i] * (i + 1);
    return sum;
}

int dpi_weigh(const int *a) { return weigh(a); }
int dpi_weigh_down(const int *a) { return weigh(a); }

void dpi_ramp(int *r)
{
    int i;
    for (i = 0; i < 4; i++)
        r[i] = 100 + i;
}

#ifdef __cplusplus
}
#endif
