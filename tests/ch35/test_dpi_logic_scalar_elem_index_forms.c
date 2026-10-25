/* C side of test_dpi_logic_scalar_elem_index_forms (IEEE 1800-2023 H.12.6). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Ranges of the actuals, visited from the left bound to the right bound. */
static const int r1[] = {2, 3, 4, 5};
static const int r2a[] = {1, 0}, r2b[] = {0, 1, 2};
static const int r3a[] = {1, 2}, r3b[] = {1, 0}, r3c[] = {3, 2};

static char name_of(svLogic v)
{
    switch (v) {
    case sv_0: return '0';
    case sv_1: return '1';
    case sv_z: return 'z';
    case sv_x: return 'x';
    default: return '?';
    }
}

static svLogic value_of(char c)
{
    return c == '1' ? sv_1 : c == 'z' ? sv_z : c == 'x' ? sv_x : sv_0;
}

/* 0 -> 1 -> z -> x -> 0 */
static svLogic next(svLogic v)
{
    return v == sv_0 ? sv_1 : v == sv_1 ? sv_z : v == sv_z ? sv_x : sv_0;
}

static void l1_line(const char *what, const svOpenArrayHandle h, int numbered)
{
    int i;

    printf("%s l1: ", what);
    for (i = 0; i < 4; i++)
        printf("%c", name_of(numbered ? svGetLogicArrElem1(h, r1[i])
                                      : svGetLogicArrElem(h, r1[i])));
    printf("\n");
}

static void l2_line(const char *what, const svOpenArrayHandle h, int numbered)
{
    int i, j;

    printf("%s l2:", what);
    for (i = 0; i < 2; i++) {
        printf(" ");
        for (j = 0; j < 3; j++)
            printf("%c", name_of(numbered ? svGetLogicArrElem2(h, r2a[i], r2b[j])
                                          : svGetLogicArrElem(h, r2a[i], r2b[j])));
    }
    printf("\n");
}

static void l3_line(const char *what, const svOpenArrayHandle h, int numbered)
{
    int i, j, k;

    printf("%s l3:", what);
    for (i = 0; i < 2; i++)
        for (j = 0; j < 2; j++) {
            printf(" ");
            for (k = 0; k < 2; k++)
                printf("%c", name_of(numbered ? svGetLogicArrElem3(h, r3a[i], r3b[j], r3c[k])
                                              : svGetLogicArrElem(h, r3a[i], r3b[j], r3c[k])));
        }
    printf("\n");
}

void c_logic_scalars(const svOpenArrayHandle l1, const svOpenArrayHandle l2,
                     const svOpenArrayHandle l3)
{
    static const char final1[] = "x10z", final2[] = "z0x1xz", final3[] = "0z1xx0z1";
    int i, j, k, n;

    l1_line("numbered get", l1, 1);
    l1_line("variable get", l1, 0);
    l2_line("numbered get", l2, 1);
    l2_line("variable get", l2, 0);
    l3_line("numbered get", l3, 1);
    l3_line("variable get", l3, 0);

    for (i = 0; i < 4; i++)
        svPutLogicArrElem1(l1, next(svGetLogicArrElem1(l1, r1[i])), r1[i]);
    for (i = 0; i < 2; i++)
        for (j = 0; j < 3; j++)
            svPutLogicArrElem2(l2, next(svGetLogicArrElem2(l2, r2a[i], r2b[j])), r2a[i],
                               r2b[j]);
    for (i = 0; i < 2; i++)
        for (j = 0; j < 2; j++)
            for (k = 0; k < 2; k++)
                svPutLogicArrElem3(l3, next(svGetLogicArrElem3(l3, r3a[i], r3b[j], r3c[k])),
                                   r3a[i], r3b[j], r3c[k]);
    l1_line("after numbered put", l1, 0);
    l2_line("after numbered put", l2, 0);
    l3_line("after numbered put", l3, 0);

    for (i = 0; i < 4; i++)
        svPutLogicArrElem(l1, value_of(final1[i]), r1[i]);
    for (n = 0, i = 0; i < 2; i++)
        for (j = 0; j < 3; j++, n++)
            svPutLogicArrElem(l2, value_of(final2[n]), r2a[i], r2b[j]);
    for (n = 0, i = 0; i < 2; i++)
        for (j = 0; j < 2; j++)
            for (k = 0; k < 2; k++, n++)
                svPutLogicArrElem(l3, value_of(final3[n]), r3a[i], r3b[j], r3c[k]);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
