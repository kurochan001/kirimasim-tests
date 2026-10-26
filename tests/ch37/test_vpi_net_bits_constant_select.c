/* VPI application of test_vpi_net_bits_constant_select (IEEE 1800-2023 37.16). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_net_bits_constant_select"
#define MAX 8

static const char *sprop(PLI_INT32 property, vpiHandle h)
{
    PLI_BYTE8 *s = h != NULL ? vpi_get_str(property, h) : NULL;
    return s != NULL ? s : "(none)";
}

static vpiHandle find(const char *name)
{
    char full[128];
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    return vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
}

static const char *net_decl(const char *name, char *out, size_t len)
{
    vpiHandle n = find(name);
    if (n == NULL) {
        snprintf(out, len, "%s: not found", name);
        return out;
    }
    snprintf(out, len, "%s: parent NULL %d, constant select %d", name,
             vpi_handle(vpiParent, n) == NULL,
             (int)vpi_get(vpiConstantSelect, n));
    return out;
}

static void bits(const char *name)
{
    vpiHandle n = find(name), it, b;
    int idx[MAX], nbits = 0, i, j, all_one = 1, expanded_bool = 1, same = 1;
    PLI_INT32 e = n != NULL ? vpi_get(vpiExpanded, n) : -1;

    it = n != NULL ? vpi_iterate(vpiBit, n) : NULL;
    while (it != NULL && (b = vpi_scan(it)) != NULL && nbits < MAX) {
        idx[nbits++] = (int)vpi_get(vpiIndex, b);
        if (vpi_get(vpiSize, b) != 1)
            all_one = 0;
        if (vpi_get(vpiExpanded, b) != e)
            same = 0;
    }
    for (i = 0; i < nbits; i++)
        for (j = i + 1; j < nbits; j++)
            if (idx[i] > idx[j]) {
                int t = idx[i];
                idx[i] = idx[j];
                idx[j] = t;
            }
    if (e != 0 && e != 1)
        expanded_bool = 0;
    vpi_printf((PLI_BYTE8 *)"%s: bits", name);
    for (i = 0; i < nbits; i++)
        vpi_printf((PLI_BYTE8 *)"%s%d", i ? "," : " ", idx[i]);
    vpi_printf((PLI_BYTE8 *)", each size 1 %d, expanded Boolean %d, same as net %d\n",
               all_one, expanded_bool, same);
}

/* The constant-select value of the RHS of the continuous assignment to y. */
static void rhs(const char *target)
{
    vpiHandle top, it, ca;

    top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    it = top != NULL ? vpi_iterate(vpiContAssign, top) : NULL;
    while (it != NULL && (ca = vpi_scan(it)) != NULL) {
        vpiHandle lhs = vpi_handle(vpiLhs, ca);
        if (lhs != NULL && strcmp(sprop(vpiName, lhs), target) == 0) {
            vpiHandle r = vpi_handle(vpiRhs, ca);
            vpi_printf((PLI_BYTE8 *)"%s: constant select %d\n", target,
                       r != NULL ? (int)vpi_get(vpiConstantSelect, r) : -1);
            vpi_release_handle(it);
            return;
        }
    }
    vpi_printf((PLI_BYTE8 *)"%s: no continuous assignment\n", target);
}

static PLI_INT32 cs_calltf(PLI_BYTE8 *user_data)
{
    char line[160];

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"%s\n", net_decl("ws", line, sizeof line));
    bits("ws");
    vpi_printf((PLI_BYTE8 *)"%s\n", net_decl("wv", line, sizeof line));
    bits("wv");
    rhs("y1");
    rhs("y2");
    rhs("y3");
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_cs";
    d.calltf = cs_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
