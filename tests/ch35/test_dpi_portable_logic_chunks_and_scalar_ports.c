#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

int portable_logic(const svLogicVecVal *data, svLogicVecVal *output_data, char *result)
{
    const unsigned top = data[2].aval & 1u;
    output_data[0].aval = data[1].aval;
    output_data[1].aval = data[0].aval;
    output_data[2].aval = top;
    output_data[0].bval = 0;
    output_data[1].bval = 0;
    output_data[2].bval = 0;
    *result = top ? -37 : 59;
    return (data[0].bval | data[1].bval | (data[2].bval & 1u)) != 0;
}

#ifdef __cplusplus
}
#endif
