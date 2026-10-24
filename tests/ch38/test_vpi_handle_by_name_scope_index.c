/* VPI application of test_vpi_handle_by_name_scope_index (IEEE 1800-2023 38.21, 38.19). */
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_handle_by_name_scope_index"

static void show(const char *what, vpiHandle h)
{
    char name[128];

    if (h == NULL) {
        vpi_printf((PLI_BYTE8 *)"%s: NULL\n", what);
        return;
    }
    strncpy(name, vpi_get_str(vpiFullName, h), sizeof name - 1);
    name[sizeof name - 1] = '\0';
    vpi_printf((PLI_BYTE8 *)"%s: %s\n", what, name);
}

static PLI_INT32 on_start(p_cb_data data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle u1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1", NULL);
    vpiHandle s = vpi_handle_by_name((PLI_BYTE8 *)TOP ".s", NULL);
    vpiHandle r = vpi_handle_by_name((PLI_BYTE8 *)TOP ".r", NULL);
    vpiHandle vec = vpi_handle_by_name((PLI_BYTE8 *)TOP ".vec", NULL);

    (void)data;
    show("top module by name, NULL scope", top);
    show("u1 by hierarchical name, NULL scope", u1);
    if (top == NULL || u1 == NULL || s == NULL || r == NULL || vec == NULL)
        return 0;
    show("u1.blk.in_blk by hierarchical name, NULL scope",
         vpi_handle_by_name((PLI_BYTE8 *)TOP ".u1.blk.in_blk", NULL));
    show("s_only, NULL scope", vpi_handle_by_name((PLI_BYTE8 *)"s_only", NULL));
    show("shared in u1", vpi_handle_by_name((PLI_BYTE8 *)"shared", u1));
    show("shared in the top module", vpi_handle_by_name((PLI_BYTE8 *)"shared", top));
    show("t_only in u1", vpi_handle_by_name((PLI_BYTE8 *)"t_only", u1));
    show("u1.s_only in the top module", vpi_handle_by_name((PLI_BYTE8 *)"u1.s_only", top));
    show("blk.in_blk in u1", vpi_handle_by_name((PLI_BYTE8 *)"blk.in_blk", u1));
    show("index 0 of the scalar s", vpi_handle_by_index(s, 0));
    show("index 0 of the real r", vpi_handle_by_index(r, 0));
    show("index 2 of vec", vpi_handle_by_index(vec, 2));
    return 0;
}

static void register_all(void)
{
    s_cb_data d;
    memset(&d, 0, sizeof d);
    d.reason = cbStartOfSimulation;
    d.cb_rtn = on_start;
    vpi_register_cb(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
