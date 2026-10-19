/* C side of test_dpi_import_small_types (IEEE 1800-2023 35.5.5, H.7.4). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

char dpi_neg_byte(char b) { return (char)-b; }
short dpi_twice_shortint(short s) { return (short)(2 * s); }
int dpi_add_int(int a, int b) { return a + b; }
long long dpi_mul_longint(long long a, long long b) { return a * b; }
double dpi_half_real(double r) { return r / 2.0; }
svBit dpi_not_bit(svBit b) { return b ? 0 : 1; }

int dpi_strlen(const char *s)
{
    int n = 0;
    while (s[n] != '\0')
        n++;
    return n;
}

const char *dpi_word(int which)
{
    static const char *words[] = {"zero", "one", "two"};
    return words[which];
}

struct dpi_counter { int value; };

void *dpi_new_counter(int start)
{
    struct dpi_counter *c = (struct dpi_counter *)malloc(sizeof *c);
    c->value = start;
    return c;
}

int dpi_next(void *c)
{
    return ++((struct dpi_counter *)c)->value;
}

#ifdef __cplusplus
}
#endif
