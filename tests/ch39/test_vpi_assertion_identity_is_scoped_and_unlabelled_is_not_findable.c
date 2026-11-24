#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_assertion_identity_is_scoped_and_unlabelled_is_not_findable"

static int resolves_unnamed(vpiHandle assertion, vpiHandle scope)
{
    const char *name = vpi_get_str(vpiName, assertion);
    if (name == NULL || *name == '\0')
        return 0;

    // Lookup can reuse simulator-owned name storage, so pass a caller copy.
    size_t size = strlen(name) + 1;
    char *copy = (char *)malloc(size);
    if (copy == NULL)
        return -1;
    memcpy(copy, name, size);
    vpiHandle by_name = vpi_handle_by_name(copy, scope);
    free(copy);
    return by_name != NULL && vpi_compare_objects(by_name, assertion);
}

static void check_scope(const char *label, vpiHandle scope, vpiHandle named)
{
    int known = 0, unknown = 0, resolves = 0;
    vpiHandle iterator = vpi_iterate(vpiAssertion, scope);
    vpiHandle current;
    while (iterator != NULL && (current = vpi_scan(iterator)) != NULL) {
        if (vpi_compare_objects(current, named)) {
            known++;
        } else {
            unknown++;
            if (resolves_unnamed(current, scope) != 0)
                resolves++;
        }
    }
    vpi_printf("%s named=%d unnamed=%d name-resolves-unnamed=%d\n",
               label, known, unknown, resolves);
}

static PLI_INT32 observe(PLI_BYTE8 *user_data)
{
    (void)user_data;
    vpiHandle left = vpi_handle_by_name((PLI_BYTE8 *)TOP ".left", NULL);
    vpiHandle right = vpi_handle_by_name((PLI_BYTE8 *)TOP ".right", NULL);
    if (left == NULL || right == NULL) {
        vpi_printf("missing instance scope\n");
        return 0;
    }

    vpiHandle left_check = vpi_handle_by_name((PLI_BYTE8 *)"test_label", left);
    vpiHandle right_check = vpi_handle_by_name((PLI_BYTE8 *)"test_label", right);
    if (left_check == NULL || right_check == NULL) {
        vpi_printf("missing named assertion\n");
        return 0;
    }
    vpi_printf("labelled distinct=%d\n", !vpi_compare_objects(left_check, right_check));
    check_scope("left", left, left_check);
    check_scope("right", right, right_check);
    return 0;
}

static void register_setup(void)
{
    s_vpi_systf_data task = {0};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$vt_check_identity";
    task.calltf = observe;
    vpi_register_systf(&task);
}

void (*vlog_startup_routines[])(void) = {register_setup, NULL};

#ifdef __cplusplus
}
#endif
