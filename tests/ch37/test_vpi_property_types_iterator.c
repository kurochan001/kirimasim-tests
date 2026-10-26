/* VPI application of test_vpi_property_types_iterator (IEEE 1800-2023 37.3.1). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_property_types_iterator"
#define MAX 8

static int by_text(const void *a, const void *b)
{
    return strcmp((const char *)a, (const char *)b);
}

static PLI_INT32 api_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)TOP, NULL);
    vpiHandle w1 = vpi_handle_by_name((PLI_BYTE8 *)TOP ".w1", NULL);
    vpiHandle co = vpi_handle_by_name((PLI_BYTE8 *)TOP ".co", NULL);
    vpiHandle it, h;
    char names[MAX][32];
    int n = 0, i;

    (void)user_data;
    vpi_printf((PLI_BYTE8 *)"vpi_get is PLI_INT32 %d\n",
               (int)(sizeof(vpi_get(vpiSize, w1)) == sizeof(PLI_INT32)));
    vpi_printf((PLI_BYTE8 *)"vpi_get64 is PLI_INT64 %d\n",
               (int)(sizeof(vpi_get64(vpiObjId, co)) == sizeof(PLI_INT64)));
    vpi_printf((PLI_BYTE8 *)"vpi_get_str is PLI_BYTE8 pointer %d\n",
               (int)(sizeof(vpi_get_str(vpiName, w1)) == sizeof(PLI_BYTE8 *)));
    vpi_printf((PLI_BYTE8 *)"Boolean properties: vector %d, scalar %d\n",
               (int)vpi_get(vpiVector, w1), (int)vpi_get(vpiScalar, w1));
    it = top != NULL ? vpi_iterate(vpiNet, top) : NULL;
    vpi_printf((PLI_BYTE8 *)"vpi_iterate gives vpiIterator %d\n",
               it != NULL && vpi_get(vpiType, it) == vpiIterator);
    while (it != NULL && (h = vpi_scan(it)) != NULL && n < MAX)
        snprintf(names[n++], sizeof names[0], "%s", vpi_get_str(vpiName, h));
    qsort(names, (size_t)n, sizeof names[0], by_text);
    vpi_printf((PLI_BYTE8 *)"nets: %d", n);
    for (i = 0; i < n; i++)
        vpi_printf((PLI_BYTE8 *)"%s%s", i ? "," : " ", names[i]);
    vpi_printf((PLI_BYTE8 *)"\n");
    vpi_printf((PLI_BYTE8 *)"object id nonzero %d\n",
               co != NULL && vpi_get64(vpiObjId, co) != 0);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_api";
    d.calltf = api_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
