/* Original test helper: IEEE 1800-2023 7.7, 35.6.1.1, H.12.2 and H.12.4. */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int visit(const svOpenArrayHandle a, int reverse_walk, int phase, int direction)
{
    int low = svLow(a, 1), high = svHigh(a, 1), n = svSize(a, 1);
    int pos, checksum = 0;
    printf("c phase=%d dims=%d left=%d right=%d low=%d high=%d inc=%d size=%d\n",
           phase, svDimensions(a), svLeft(a, 1), svRight(a, 1), low, high,
           svIncrement(a, 1), n);
    for (pos = 0; pos < n; ++pos) {
        int i = reverse_walk ? high - pos : low + pos;
        int *element = (int *)svGetArrElemPtr1(a, i);
        int before, after;
        if (element == NULL) {
            printf("c missing index=%d\n", i);
            fflush(stdout);
            return -99999;
        }
        before = direction == 1 ? 0 : *element;
        after = direction == 1 ? -100 * (phase + 1) + 3 * i :
                direction == 2 ? before + 100 * (phase + 1) + i : before;
        if (direction != 0)
            *element = after;
        printf("c index=%d before=%d after=%d\n", i, before, after);
        checksum += (pos + 1) * after;
    }
    fflush(stdout);
    return checksum;
}

int cross_dpi_array_input(const svOpenArrayHandle a, int reverse_walk, int phase)
{
    return visit(a, reverse_walk, phase, 0);
}

int cross_dpi_array_output(const svOpenArrayHandle a, int reverse_walk, int phase)
{
    return visit(a, reverse_walk, phase, 1);
}

int cross_dpi_array_inout(const svOpenArrayHandle a, int reverse_walk, int phase)
{
    return visit(a, reverse_walk, phase, 2);
}

#ifdef __cplusplus
}
#endif
