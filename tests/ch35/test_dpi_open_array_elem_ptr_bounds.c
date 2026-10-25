/* C side of test_dpi_open_array_elem_ptr_bounds (IEEE 1800-2023 H.12.4). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static void one(const svOpenArrayHandle a, int i)
{
    void *p = svGetArrElemPtr1(a, i);
    void *v = svGetArrElemPtr(a, i);

    if (p == NULL) {
        printf("a[%d]: NULL, svGetArrElemPtr NULL %d\n", i, v == NULL);
        return;
    }
    printf("a[%d]: %d, svGetArrElemPtr same %d\n", i, *(int *)p, v == p);
    *(int *)p += 1000;
}

static void two(const svOpenArrayHandle r, int i, int j)
{
    void *p = svGetArrElemPtr2(r, i, j);
    void *v = svGetArrElemPtr(r, i, j);

    if (p == NULL) {
        printf("r[%d][%d]: NULL, svGetArrElemPtr NULL %d\n", i, j, v == NULL);
        return;
    }
    printf("r[%d][%d]: %.1f, svGetArrElemPtr same %d\n", i, j, *(double *)p, v == p);
    *(double *)p *= 2.0;
}

static void three(const svOpenArrayHandle s, int i, int j, int k)
{
    void *p = svGetArrElemPtr3(s, i, j, k);
    void *v = svGetArrElemPtr(s, i, j, k);

    if (p == NULL) {
        printf("s[%d][%d][%d]: NULL, svGetArrElemPtr NULL %d\n", i, j, k, v == NULL);
        return;
    }
    printf("s[%d][%d][%d]: %d, svGetArrElemPtr same %d\n", i, j, k, (int)*(short *)p, v == p);
    *(short *)p = (short)-*(short *)p;
}

void c_elems(const svOpenArrayHandle a, const svOpenArrayHandle r, const svOpenArrayHandle s)
{
    int i;

    for (i = 1; i <= 6; i++)
        one(a, i);

    two(r, 0, 3);
    two(r, 0, 1);
    two(r, 1, 2);
    two(r, 1, 1);
    two(r, -1, 2);
    two(r, 2, 1);
    two(r, 0, 0);
    two(r, 1, 4);

    three(s, 1, 2, 0);
    three(s, 2, 1, 1);
    three(s, 2, 2, 0);
    three(s, 0, 1, 0);
    three(s, 3, 2, 1);
    three(s, 1, 0, 1);
    three(s, 2, 3, 0);
    three(s, 1, 1, -1);
    three(s, 2, 2, 2);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
