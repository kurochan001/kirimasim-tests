/* VPI application of test_vpi_user_h_macro_cleanup
   (IEEE 1800-2023 36.7, K.2). */
/* The application supplies its own helper macros and DLL qualifiers before
   the header, so the cleanup at the end of the header has something of the
   application to keep and something of both to remove. The qualifiers stand
   for an empty token sequence of their own, which keeps the declarations
   usable. */
#define PLI_EXTERN
#define PLI_VEXTERN extern
#define PLI_PROTOTYPES
#define PROTO_PARAMS(params) params
#define XXTERN extern
#define EETERN extern
#define PLI_DLLISPEC
#define PLI_DLLESPEC
#include "vpi_user.h"
#include <string.h>

#ifdef PLI_EXTERN
#define VT_EXTERN_LEFT 1
#else
#define VT_EXTERN_LEFT 0
#endif
#ifdef PLI_VEXTERN
#define VT_VEXTERN_LEFT 1
#else
#define VT_VEXTERN_LEFT 0
#endif
#ifdef PLI_PROTOTYPES
#define VT_PROTOTYPES_LEFT 1
#else
#define VT_PROTOTYPES_LEFT 0
#endif
#ifdef PROTO_PARAMS
#define VT_PROTO_PARAMS_LEFT 1
#else
#define VT_PROTO_PARAMS_LEFT 0
#endif
#ifdef XXTERN
#define VT_XXTERN_LEFT 1
#else
#define VT_XXTERN_LEFT 0
#endif
#ifdef EETERN
#define VT_EETERN_LEFT 1
#else
#define VT_EETERN_LEFT 0
#endif
#ifdef PLI_DLLISPEC
#define VT_DLLISPEC_LEFT 1
#else
#define VT_DLLISPEC_LEFT 0
#endif
#ifdef PLI_DLLESPEC
#define VT_DLLESPEC_LEFT 1
#else
#define VT_DLLESPEC_LEFT 0
#endif
#ifdef VPI_USER_DEFINED_DLLISPEC
#define VT_DLLISPEC_FLAG 1
#else
#define VT_DLLISPEC_FLAG 0
#endif
#ifdef VPI_USER_DEFINED_DLLESPEC
#define VT_DLLESPEC_FLAG 1
#else
#define VT_DLLESPEC_FLAG 0
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))

static PLI_INT32 check_all(p_cb_data data)
{
    (void)data;
    CHECK("PLI_EXTERN removed after the header", VT_EXTERN_LEFT == 0);
    CHECK("PLI_VEXTERN removed after the header", VT_VEXTERN_LEFT == 0);
    CHECK("PLI_PROTOTYPES removed after the header", VT_PROTOTYPES_LEFT == 0);
    CHECK("PROTO_PARAMS removed after the header", VT_PROTO_PARAMS_LEFT == 0);
    CHECK("XXTERN removed after the header", VT_XXTERN_LEFT == 0);
    CHECK("EETERN removed after the header", VT_EETERN_LEFT == 0);
    CHECK("application PLI_DLLISPEC still defined after the header",
          VT_DLLISPEC_LEFT == 1);
    CHECK("application PLI_DLLESPEC still defined after the header",
          VT_DLLESPEC_LEFT == 1);
    CHECK("no cleanup flag for an application DLL qualifier",
          !VT_DLLISPEC_FLAG && !VT_DLLESPEC_FLAG);
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = check_all;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
