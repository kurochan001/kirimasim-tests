#ifndef VPI_EXTENDED_ATTRIBUTES_CLIENT_H
#define VPI_EXTENDED_ATTRIBUTES_CLIENT_H

#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

enum {
    PRIMITIVE_TERMINALS, PATH_TERMINALS, MODULE_PATHS, TIMING_CHECKS, TABLE_ENTRIES,
    ATTRIBUTE_GROUPS,
};
enum { ATTRIBUTES_PER_GROUP = 3 };

typedef struct {
    vpiHandle first;
    vpiHandle second;
} owner_pair;

typedef struct {
    vpiHandle owner;
    const char *name;
    PLI_INT32 format;
    int value;
} attribute_request;

#ifdef SEED_EXTENDED_ATTRIBUTES
int attach_fixture_attributes(const attribute_request *requests, size_t count,
                              vpiHandle wrong_parent, vpiHandle wrong_iterator_owner);
#endif

#ifdef __cplusplus
}
#endif
#endif
