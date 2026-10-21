/* C side of test_dpi_import_unit_interface_program (IEEE 1800-2023 35.2.1). */
#include <stdio.h>
#include <stdlib.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

static int tickets;
static int slots[8];

int c_next_ticket(void)
{
    return ++tickets;
}

void c_store(int slot, int value)
{
    slots[slot] = value;
}

int c_load(int slot)
{
    return slots[slot];
}

int c_sum_into(int *total, int a, int b)
{
    *total = a + b;
    return 0;
}

#ifdef __cplusplus
}
#endif
