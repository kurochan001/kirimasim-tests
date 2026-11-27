#ifndef VPI_INTERFACE_OWNERSHIP_CLIENT_H
#define VPI_INTERFACE_OWNERSHIP_CLIENT_H

#include "sv_vpi_user.h"

typedef struct {
    vpiHandle top, timing, physical, physical_array, path[2], program[2], scalar[2], array[2];
} design_handles;

#ifdef SEED_INTERFACE_OWNERSHIP
#ifdef __cplusplus
extern "C" {
#endif

int attach_fixture_ownership(const design_handles *design);

#ifdef __cplusplus
}
#endif
#endif

#endif
