#ifndef TEST_VPI_MISC_FORMATS_H
#define TEST_VPI_MISC_FORMATS_H

#include "vpi_user.h"

enum {
    testFormatNamespace = 0x4b540100,
    testBitPlanes = testFormatNamespace + 1,
    testStateCounts = testFormatNamespace + 2,
    testUnregistered = testFormatNamespace + 3
};

/* This reference provider supports packed values of up to 64 bits. */
struct bit_planes {
    PLI_INT32 width;
    s_vpi_vecval words[2];
};

struct state_counts {
    PLI_INT32 zero, one, x, z;
};

void reference_get_value(vpiHandle object, p_vpi_value value);

#endif
