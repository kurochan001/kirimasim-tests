/* C side of test_dpi_open_array_unsized_ranges_per_call (IEEE 1800-2023 H.12, H.6.1). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_show(const char *name, const svOpenArrayHandle x)
{
    int s1 = svLeft(x, 1) <= svRight(x, 1) ? 1 : -1;
    int s2 = svLeft(x, 2) <= svRight(x, 2) ? 1 : -1;
    unsigned mask = (1u << svSize(x, 0)) - 1u;
    int i, j;

    printf("%s: dimension 0 %d:%d, dimension 1 %d:%d, dimension 2 %d:%d\n", name, svLeft(x, 0),
           svRight(x, 0), svLeft(x, 1), svRight(x, 1), svLeft(x, 2), svRight(x, 2));
    printf("%s:", name);
    for (i = svLeft(x, 1); i != svRight(x, 1) + s1; i += s1)
        for (j = svLeft(x, 2); j != svRight(x, 2) + s2; j += s2) {
            svBitVecVal v = 0;
            svGetBitArrElem2VecVal(&v, x, i, j);
            printf(" [%d][%d] %02x", i, j, (unsigned)(v & mask));
        }
    printf("\n");
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
