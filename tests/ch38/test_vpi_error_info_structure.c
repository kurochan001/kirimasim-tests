/* VPI application of test_vpi_error_info_structure (IEEE 1800-2023 38.2). */
#include <stddef.h>
#include <string.h>
#include "vpi_user.h"

/* SAME_TYPE(e, T) is 1 when the unevaluated expression e has exactly type T. */
#ifdef __cplusplus
template <typename A, typename B> struct vt_same { enum { value = 0 }; };
template <typename A> struct vt_same<A, A> { enum { value = 1 }; };
#define SAME_TYPE(e, T) ((int)vt_same<decltype(e), T>::value)
#else
#define SAME_TYPE(e, T) _Generic((e), T: 1, default: 0)
#endif

#ifdef __cplusplus
extern "C" {
#endif

#define CHECK(what, ok) vpi_printf((PLI_BYTE8 *)"%s %d\n", what, (int)(ok))
/* No parentheses around the member access: decltype gives its declared type. */
#define FIELD(f) ((s_vpi_error_info *)0)->f
#define AT(f) offsetof(s_vpi_error_info, f)

static const PLI_INT32 levels[5] = {vpiNotice, vpiWarning, vpiError, vpiSystem, vpiInternal};
static const char *const level_names[5] = {"vpiNotice", "vpiWarning", "vpiError", "vpiSystem",
                                           "vpiInternal"};

static PLI_INT32 check_all(p_cb_data data)
{
    int k, j;

    (void)data;
    CHECK("p_vpi_error_info points to s_vpi_error_info (struct t_vpi_error_info)",
          SAME_TYPE((p_vpi_error_info)0, struct t_vpi_error_info *) &&
          SAME_TYPE((s_vpi_error_info *)0, struct t_vpi_error_info *));
    CHECK("state PLI_INT32", SAME_TYPE(FIELD(state), PLI_INT32));
    CHECK("level PLI_INT32", SAME_TYPE(FIELD(level), PLI_INT32));
    CHECK("message PLI_BYTE8 *", SAME_TYPE(FIELD(message), PLI_BYTE8 *));
    CHECK("product PLI_BYTE8 *", SAME_TYPE(FIELD(product), PLI_BYTE8 *));
    CHECK("code PLI_BYTE8 *", SAME_TYPE(FIELD(code), PLI_BYTE8 *));
    CHECK("file PLI_BYTE8 *", SAME_TYPE(FIELD(file), PLI_BYTE8 *));
    CHECK("line PLI_INT32", SAME_TYPE(FIELD(line), PLI_INT32));
    CHECK("order state level message product code file line",
          AT(state) < AT(level) && AT(level) < AT(message) && AT(message) < AT(product) &&
          AT(product) < AT(code) && AT(code) < AT(file) && AT(file) < AT(line));
    vpi_printf((PLI_BYTE8 *)"states vpiCompile %d vpiPLI %d vpiRun %d\n", (int)vpiCompile,
               (int)vpiPLI, (int)vpiRun);
    for (k = 0; k < 5; k++) {
        int rank = 0;
        for (j = 0; j < 5; j++)
            if (levels[j] <= levels[k])
                rank++;
        vpi_printf((PLI_BYTE8 *)"%s value %d rank %d of 5\n", level_names[k], (int)levels[k],
                   rank);
    }
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
