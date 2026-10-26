/* C side of test_dpi_open_and_unsized_packed (IEEE 1800-2023 7.7). */
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void dpi_info(const svOpenArrayHandle a, const svOpenArrayHandle v,
              int *asize, int *aleft, int *aright,
              int *psize, int *pleft, int *pright)
{
    *asize = svSize(a, 1);
    *aleft = svLeft(a, 1);
    *aright = svRight(a, 1);
    *psize = svSize(v, 0);
    *pleft = svLeft(v, 0);
    *pright = svRight(v, 0);
}

#ifdef __cplusplus
}
#endif
