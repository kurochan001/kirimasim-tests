/* C side of test_dpi_context_scope_switch (IEEE 1800-2023 H.6.5, H.9.1). */
#include "svdpi.h"
#include <stdio.h>
#include <string.h>

#ifdef __cplusplus
extern "C" {
#endif

extern int sv_unit_id(void);

static svScope saved[3];

void c_note(int slot)
{
    if (slot >= 1 && slot <= 2)
        saved[slot] = svGetScope();
}

void c_step(int slot, int mode)
{
    if (mode == 0) {
        printf("u%d default scope %d\n", slot, sv_unit_id());
    } else if (mode == 2) {
        svScope here = svGetScope();

        svSetScope(saved[2]);
        printf("u%d with the scope of u2 %d\n", slot, sv_unit_id());
        svSetScope(here);
        printf("u%d default scope after the switch %d\n", slot, sv_unit_id());
    } else if (mode == 1) {
        const char *first = svGetNameFromScope(saved[1]);
        const char *second = svGetNameFromScope(saved[2]);

        printf("import scopes name the two instances %d\n",
               first != NULL && strcmp(first,
                   "test_dpi_context_scope_switch.u1") == 0 &&
               second != NULL && strcmp(second,
                   "test_dpi_context_scope_switch.u2") == 0);
    }
    fflush(stdout);
}

#ifdef __cplusplus
}
#endif
