/* C side of test_dpi_formal_integer_logic_time (IEEE 1800-2023 35.5.6). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_combine(const svLogicVecVal *i, const svLogicVecVal *t, svLogic l);

int dpi_logic_code(svLogic l)
{
    return (int)l;
}

void dpi_make_logic(svLogic *l)
{
    *l = sv_z;
}

void dpi_integer_planes(const svLogicVecVal *i, int *a, int *b)
{
    *a = (int)i[0].aval;
    *b = (int)i[0].bval;
}

void dpi_make_integer(svLogicVecVal *i)
{
    i[0].aval = 0xffffff80u;
    i[0].bval = 0;
}

void dpi_time_words(const svLogicVecVal *t, int *lo, int *hi)
{
    *lo = (int)t[0].aval;
    *hi = (int)t[1].aval;
}

void dpi_make_time(svLogicVecVal *t)
{
    t[0].aval = 9;
    t[0].bval = 0;
    t[1].aval = 1;
    t[1].bval = 0;
}

int dpi_call_export(void)
{
    svLogicVecVal i[1], t[2];

    i[0].aval = 30;
    i[0].bval = 0;
    t[0].aval = 12;
    t[0].bval = 0;
    t[1].aval = 0;
    t[1].bval = 0;
    return sv_combine(i, t, sv_z);
}

#ifdef __cplusplus
}
#endif
