#include "vpi_user.h"

#define VPI_NAME_LITERAL(symbol) #symbol
#define VPI_NAME(symbol) VPI_NAME_LITERAL(symbol)

#ifdef __cplusplus
extern "C" {
#endif

PLI_INT32 vpi_mode_selection_callback(struct t_cb_data *data)
{
    (void)data;
    vpi_printf("callback %s\n", VPI_NAME(vpi_get));
    return 0;
}

#ifdef __cplusplus
}
#endif
