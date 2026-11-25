/* The two probe branches are used only when preprocessing this file. */
#if defined(PROBE_CALLER_EXTERN)
#define DPI_EXTERN probe_caller_extern
#elif defined(PROBE_CALLER_PROTOTYPES)
#define DPI_PROTOTYPES
#define XXTERN probe_caller_import
#define EETERN probe_caller_export
#endif

#include "svdpi.h"

#if defined(DPI_PROTOTYPES) || defined(DPI_EXTERN) || defined(XXTERN) || defined(EETERN)
#error "DPI declaration helpers remain defined after including svdpi.h"
#endif

#ifdef __cplusplus
extern "C"
#endif
int dpi_prototype_guard_version_available(void)
{
    return svDpiVersion() != 0;
}
