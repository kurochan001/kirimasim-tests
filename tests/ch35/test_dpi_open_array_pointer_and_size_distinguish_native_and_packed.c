#include <stdio.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void inspect_layout(const svOpenArrayHandle native, const svOpenArrayHandle packed)
{
    const int *pointer = (const int *)svGetArrayPtr(native);
    int size_matches = svSizeOfArray(native) == (int)(3 * sizeof *pointer);
    int extremes_match = pointer != NULL && size_matches && pointer[0] == 31 && pointer[2] == 59;
    printf("native pointer=%d bytes=%d extremes=%d\n", pointer != NULL,
           size_matches, extremes_match);

    const void *canonical_pointer = svGetArrayPtr(packed);
    int canonical_size = svSizeOfArray(packed);
    svLogicVecVal element = {0};
    svGetLogicArrElemVecVal(&element, packed, 2);
    int bits_match = (element.aval & 0x3fu) == 0x19u && (element.bval & 0x3fu) == 0x0au;
    printf("packed pointer null=%d bytes zero=%d four-state value=%d\n",
           canonical_pointer == NULL, canonical_size == 0, bits_match);
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
