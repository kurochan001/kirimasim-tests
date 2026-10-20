/* C side of test_dpi_open_array_2d (IEEE 1800-2023 35.5.6.1, H.12). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* dimensions, then left, right and size of each dimension, as decimal digits */
int dpi_shape(const svOpenArrayHandle m)
{
    int d, v = svDimensions(m);
    for (d = 1; d <= 2; d++)
        v = ((v * 10 + svLeft(m, d)) * 10 + svRight(m, d)) * 10 + svSize(m, d);
    return v;
}

static int at(const svOpenArrayHandle m, int i, int j)
{
    return *(const int *)svGetArrElemPtr2(m, i, j);
}

int dpi_corner_sum(const svOpenArrayHandle m)
{
    return at(m, 2, 1) + at(m, 2, 3) + at(m, 0, 1) + at(m, 0, 3);
}

#ifdef __cplusplus
}
#endif
