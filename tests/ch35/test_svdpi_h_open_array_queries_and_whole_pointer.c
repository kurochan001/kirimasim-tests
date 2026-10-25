/* C side of test_svdpi_h_open_array_queries_and_whole_pointer (I.3, H.12.2, H.12.4). */
#include "svdpi.h"
#include <stddef.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

static void query(const char *who, const svOpenArrayHandle h, int d)
{
    printf("%s dim %d: left %d right %d low %d high %d increment %d size %d\n", who, d,
           svLeft(h, d), svRight(h, d), svLow(h, d), svHigh(h, d), svIncrement(h, d),
           svSize(h, d));
}

void c_queries(const svOpenArrayHandle h)
{
    printf("svDimensions gives %d\n", svDimensions(h));
    query("C packed", h, 0);
    query("C unpacked", h, 1);
    fflush(stdout);
}

static void agree(const char *what, const svOpenArrayHandle h)
{
    printf("%s: address and size both given or both 0 %d\n", what,
           (svGetArrayPtr(h) != NULL) == (svSizeOfArray(h) != 0));
}

void c_whole(const svOpenArrayHandle a, const svOpenArrayHandle m,
             const svOpenArrayHandle p, const svOpenArrayHandle s)
{
    int *ap = (int *)svGetArrayPtr(a);
    int *mp = (int *)svGetArrayPtr(m);

    printf("int a[0:3]: address %d, size %d\n", ap != NULL, svSizeOfArray(a));
    if (ap != NULL)
        printf("through the address: %d %d %d %d\n", ap[0], ap[1], ap[2], ap[3]);
    printf("int m[0:1][0:2]: address %d, size %d\n", mp != NULL, svSizeOfArray(m));
    if (mp != NULL)
        printf("through the address: %d %d %d %d %d %d\n", mp[0], mp[1], mp[2], mp[3], mp[4],
               mp[5]);
    agree("logic [7:0] p[0:3]", p);
    agree("string s[0:3]", s);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
