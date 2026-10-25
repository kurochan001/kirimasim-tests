/* C side of test_dpi_bit_scalar_elem_index_forms (IEEE 1800-2023 H.12.6). */
#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Ranges of the actuals, visited from the left bound to the right bound. */
static const int r1[] = {2, 3, 4, 5};
static const int r2a[] = {1, 0}, r2b[] = {0, 1, 2};
static const int r3a[] = {1, 2}, r3b[] = {1, 0}, r3c[] = {3, 2};

static void s1_line(const char *what, const svOpenArrayHandle h, int numbered)
{
    int i;

    printf("%s s1:", what);
    printf(" ");
    for (i = 0; i < 4; i++)
        printf("%d", (int)(numbered ? svGetBitArrElem1(h, r1[i]) : svGetBitArrElem(h, r1[i])));
    printf("\n");
}

static void s2_line(const char *what, const svOpenArrayHandle h, int numbered)
{
    int i, j;

    printf("%s s2:", what);
    for (i = 0; i < 2; i++) {
        printf(" ");
        for (j = 0; j < 3; j++)
            printf("%d", (int)(numbered ? svGetBitArrElem2(h, r2a[i], r2b[j])
                                        : svGetBitArrElem(h, r2a[i], r2b[j])));
    }
    printf("\n");
}

static void s3_line(const char *what, const svOpenArrayHandle h, int numbered)
{
    int i, j, k;

    printf("%s s3:", what);
    for (i = 0; i < 2; i++)
        for (j = 0; j < 2; j++) {
            printf(" ");
            for (k = 0; k < 2; k++)
                printf("%d", (int)(numbered ? svGetBitArrElem3(h, r3a[i], r3b[j], r3c[k])
                                            : svGetBitArrElem(h, r3a[i], r3b[j], r3c[k])));
        }
    printf("\n");
}

static svBit flip(svBit b) { return b == sv_0 ? sv_1 : sv_0; }

static svBit bit_of(char c) { return c == '1' ? sv_1 : sv_0; }

void c_bit_scalars(const svOpenArrayHandle s1, const svOpenArrayHandle s2,
                   const svOpenArrayHandle s3)
{
    static const char final1[] = "0111", final2[] = "010111", final3[] = "00101011";
    int i, j, k, n;

    s1_line("numbered get", s1, 1);
    s1_line("variable get", s1, 0);
    s2_line("numbered get", s2, 1);
    s2_line("variable get", s2, 0);
    s3_line("numbered get", s3, 1);
    s3_line("variable get", s3, 0);

    for (i = 0; i < 4; i++)
        svPutBitArrElem1(s1, flip(svGetBitArrElem1(s1, r1[i])), r1[i]);
    for (i = 0; i < 2; i++)
        for (j = 0; j < 3; j++)
            svPutBitArrElem2(s2, flip(svGetBitArrElem2(s2, r2a[i], r2b[j])), r2a[i], r2b[j]);
    for (i = 0; i < 2; i++)
        for (j = 0; j < 2; j++)
            for (k = 0; k < 2; k++)
                svPutBitArrElem3(s3, flip(svGetBitArrElem3(s3, r3a[i], r3b[j], r3c[k])),
                                 r3a[i], r3b[j], r3c[k]);
    s1_line("after numbered put", s1, 0);
    s2_line("after numbered put", s2, 0);
    s3_line("after numbered put", s3, 0);

    for (i = 0; i < 4; i++)
        svPutBitArrElem(s1, bit_of(final1[i]), r1[i]);
    for (n = 0, i = 0; i < 2; i++)
        for (j = 0; j < 3; j++, n++)
            svPutBitArrElem(s2, bit_of(final2[n]), r2a[i], r2b[j]);
    for (n = 0, i = 0; i < 2; i++)
        for (j = 0; j < 2; j++)
            for (k = 0; k < 2; k++, n++)
                svPutBitArrElem(s3, bit_of(final3[n]), r3a[i], r3b[j], r3c[k]);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
