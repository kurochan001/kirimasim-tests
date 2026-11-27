#ifndef VPI_PATTERN_CONSTRAINT_PROPERTIES_CLIENT_H
#define VPI_PATTERN_CONSTRAINT_PROPERTIES_CLIENT_H

#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#ifdef SEED_PATTERN_CONSTRAINT
int set_constraint_virtual(vpiHandle object, const char *name);
int set_pattern_member_name(vpiHandle object, const char *binding);
#endif

#ifdef __cplusplus
}
#endif

#endif
