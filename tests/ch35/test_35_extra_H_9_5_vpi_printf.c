/* C side of test_35_extra_H_9_5_vpi_printf (IEEE 1800-2023 H.9.5). */
#include "vpi_user.h"
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

void c_vpi_printf(void)
{
    vpi_printf((PLI_BYTE8 *)"vpi printf from a noncontext import\n");
    vpi_flush();
}

#ifdef __cplusplus
}
#endif
