/* Test-owned DPI probe for IEEE 1800-2023 20.7 and H.12.2. */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int cross_dpiquery(const svOpenArrayHandle a, int phase)
{
    int dims = svDimensions(a), result = 0;
    printf("c phase=%d dims=%d\n", phase, dims);
    if (dims < 1 || dims > 3) {
        puts("unexpected rank");
        fflush(stdout);
        return -1;
    }
    for (int d = 0; d <= dims; ++d) {
        int l = svLeft(a, d), r = svRight(a, d);
        int low = svLow(a, d), high = svHigh(a, d);
        int inc = svIncrement(a, d), size = svSize(a, d);
        printf("c dim=%d left=%d right=%d low=%d high=%d increment=%d size=%d\n",
               d, l, r, low, high, inc, size);
        result += (d + 1) * (7*l + 11*r + 13*low + 17*high + 19*inc + 23*size);
    }
    fflush(stdout);
    return result;
}

#ifdef __cplusplus
}
#endif
