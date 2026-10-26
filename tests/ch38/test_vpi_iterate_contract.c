/* VPI application of test_vpi_iterate_contract (IEEE 1800-2023 38.23). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static int cmp(const void *x, const void *y)
{
    return strcmp((const char *)x, (const char *)y);
}

static PLI_INT32 iter_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_iterate_contract",
                                       NULL);
    vpiHandle it, net;
    char names[8][64];
    int count = 0, k;
    int same = 1;

    (void)user_data;
    if (mod == NULL) {
        vpi_printf((PLI_BYTE8 *)"module not found\n");
        return 0;
    }
    it = vpi_iterate(vpiNet, mod);
    vpi_printf((PLI_BYTE8 *)"vpi_iterate(vpiNet) is a vpiIterator handle: %d\n",
               it != NULL && vpi_get(vpiType, it) == vpiIterator);
    while (it != NULL && (net = vpi_scan(it)) != NULL && count < 8) {
        char full[64];

        strncpy(names[count], vpi_get_str(vpiName, net), 63);
        names[count][63] = '\0';
        strncpy(full, vpi_get_str(vpiFullName, net), 63);
        full[63] = '\0';
        {
            vpiHandle named = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
            if (named == NULL || !vpi_compare_objects(net, named))
                same = 0;
        }
        count++;
    }
    vpi_printf((PLI_BYTE8 *)"scanned handles are the named objects: %d\n", same);
    qsort(names, count, sizeof names[0], cmp);
    vpi_printf((PLI_BYTE8 *)"nets: %d", count);
    for (k = 0; k < count; k++)
        vpi_printf((PLI_BYTE8 *)" %s", names[k]);
    vpi_printf((PLI_BYTE8 *)"\n");
    vpi_printf((PLI_BYTE8 *)"no UDP definition: %d\n",
               vpi_iterate(vpiUdpDefn, mod) == NULL);
    vpi_printf((PLI_BYTE8 *)"no module path: %d\n",
               vpi_iterate(vpiModPath, mod) == NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;

    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_iter";
    d.calltf = iter_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
