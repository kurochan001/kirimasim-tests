#include <stddef.h>
#include "formats.h"

void reference_get_value(vpiHandle object, p_vpi_value value)
{
    static struct bit_planes planes;
    static struct state_counts counts;
    switch (value->format) {
    case testBitPlanes:
    case testStateCounts:
        break;
    default:
        if ((value->format & ~0xff) == testFormatNamespace) {
            value->format = vpiSuppressVal;
            value->value.misc = NULL;
        } else {
            vpi_get_value(object, value);
        }
        return;
    }

    PLI_INT32 width = vpi_get(vpiSize, object);
    s_vpi_value source = { .format = vpiVectorVal };
    vpi_get_value(object, &source);
    if (width < 1 || width > 64 || source.format != vpiVectorVal || source.value.vector == NULL) {
        value->format = vpiSuppressVal;
        value->value.misc = NULL;
        return;
    }

    if (value->format == testBitPlanes) {
        planes = (struct bit_planes){ .width = width };
        for (PLI_INT32 word = 0; word < (width + 31) / 32; ++word)
            planes.words[word] = source.value.vector[word];
        value->value.misc = (PLI_BYTE8 *)&planes;
        return;
    }

    counts = (struct state_counts){0};
    for (PLI_INT32 bit = 0; bit < width; ++bit) {
        const s_vpi_vecval word = source.value.vector[bit / 32];
        const PLI_UINT32 mask = (PLI_UINT32)1 << (bit % 32);
        if (word.bval & mask) {
            if (word.aval & mask)
                ++counts.x;
            else
                ++counts.z;
        } else if (word.aval & mask) {
            ++counts.one;
        } else {
            ++counts.zero;
        }
    }
    value->value.misc = (PLI_BYTE8 *)&counts;
}
