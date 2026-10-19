/* VPI application of test_vpi_type_strings (IEEE 1800-2023 37.3.2). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_type_strings"

struct item {
    const char *name;   /* relative to the module; "" for the module */
    int bit;            /* index of a bit, or -1 */
    PLI_INT32 type;
    const char *spelling;
    const char *other;  /* the second accepted spelling, or NULL */
};

static const struct item items[] = {
    {"", -1, vpiModule, "vpiModule", NULL},
    {"w", -1, vpiNet, "vpiNet", "vpiLogicNet"},
    {"w", 2, vpiNetBit, "vpiNetBit", NULL},
    {"r", -1, vpiReg, "vpiReg", "vpiLogicVar"},
    {"r", 2, vpiRegBit, "vpiRegBit", "vpiVarBit"},
    {"i", -1, vpiIntegerVar, "vpiIntegerVar", NULL},
    {"re", -1, vpiRealVar, "vpiRealVar", NULL},
    {"t", -1, vpiTimeVar, "vpiTimeVar", NULL},
    {"ii", -1, vpiIntVar, "vpiIntVar", NULL},
    {"bv", -1, vpiBitVar, "vpiBitVar", NULL},
    {"by", -1, vpiByteVar, "vpiByteVar", NULL},
    {"mem", -1, vpiRegArray, "vpiRegArray", "vpiArrayVar"},
    {"ev", -1, vpiNamedEvent, "vpiNamedEvent", NULL},
    {"P", -1, vpiParameter, "vpiParameter", NULL},
    {"blk", -1, vpiNamedBegin, "vpiNamedBegin", NULL},
    {"tk", -1, vpiTask, "vpiTask", NULL},
    {"fn", -1, vpiFunction, "vpiFunction", NULL},
};

struct net_type {
    const char *name;
    PLI_INT32 type;
    const char *spelling;
};

static const struct net_type net_types[] = {
    {"w", vpiWire, "vpiWire"},
    {"wa", vpiWand, "vpiWand"},
    {"t1", vpiTri1, "vpiTri1"},
    {"s0", vpiSupply0, "vpiSupply0"},
};

static vpiHandle find(const char *name)
{
    char full[64];
    snprintf(full, sizeof full, "%s%s%s", TOP, name[0] ? "." : "", name);
    return vpi_handle_by_name(full, NULL);
}

static PLI_INT32 types_calltf(PLI_BYTE8 *user_data)
{
    int i;

    (void)user_data;
    for (i = 0; i < (int)(sizeof items / sizeof items[0]); i++) {
        const struct item *e = &items[i];
        vpiHandle h = find(e->name);
        PLI_BYTE8 *s;
        char label[16];

        if (h != NULL && e->bit >= 0)
            h = vpi_handle_by_index(h, e->bit);
        if (e->bit >= 0)
            snprintf(label, sizeof label, "%s[%d]", e->name, e->bit);
        else
            snprintf(label, sizeof label, "%s", e->name[0] ? e->name : "module");
        if (h == NULL) {
            vpi_printf("%s: not found\n", label);
            continue;
        }
        s = vpi_get_str(vpiType, h);
        if (s != NULL
            && (strcmp(s, e->spelling) == 0 || (e->other && strcmp(s, e->other) == 0))) {
            if (e->other)
                vpi_printf("%s: %s or %s", label, e->spelling, e->other);
            else
                vpi_printf("%s: %s", label, e->spelling);
        } else {
            vpi_printf("%s: %s", label, s ? s : "(null)");
        }
        vpi_printf(", vpi_get(vpiType) %s\n", vpi_get(vpiType, h) == e->type ? "matches" : "differs");
    }
    for (i = 0; i < (int)(sizeof net_types / sizeof net_types[0]); i++) {
        const struct net_type *e = &net_types[i];
        vpiHandle h = find(e->name);
        PLI_BYTE8 *s = h ? vpi_get_str(vpiNetType, h) : NULL;
        vpi_printf("%s: net type %s, vpi_get(vpiNetType) %s\n", e->name, s ? s : "(null)",
                   h && vpi_get(vpiNetType, h) == e->type ? "matches" : "differs");
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_types";
    d.calltf = types_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
