/* VPI application of test_vpi_iterator_objects (IEEE 1800-2023 37.84). */
#include <stdio.h>
#include <string.h>
#include "vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 iterators_calltf(PLI_BYTE8 *user_data)
{
    vpiHandle mod = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_iterator_objects", NULL);
    vpiHandle it, tops, use;
    int n = 0;

    (void)user_data;
    it = vpi_iterate(vpiNet, mod);
    if (it == NULL) {
        vpi_printf((PLI_BYTE8 *)"nets: no iterator\n");
    } else {
        use = vpi_handle(vpiUse, it);
        vpi_printf((PLI_BYTE8 *)"nets: type is iterator %d, iterator type is net %d, "
                   "use is module %d\n", vpi_get(vpiType, it) == vpiIterator,
                   vpi_get(vpiIteratorType, it) == vpiNet,
                   use != NULL && vpi_compare_objects(use, mod));
        while (vpi_scan(it) != NULL)
            n++;
        vpi_printf((PLI_BYTE8 *)"nets: %d scanned\n", n);
    }

    tops = vpi_iterate(vpiModule, NULL);
    if (tops == NULL) {
        vpi_printf((PLI_BYTE8 *)"top modules: no iterator\n");
    } else {
        vpi_printf((PLI_BYTE8 *)"top modules: iterator type is module %d, use is NULL %d\n",
                   vpi_get(vpiIteratorType, tops) == vpiModule, vpi_handle(vpiUse, tops) == NULL);
        vpi_scan(tops);
        vpi_printf((PLI_BYTE8 *)"top modules: released after one scan %d\n",
                   (int)vpi_release_handle(tops));
    }

    vpi_printf((PLI_BYTE8 *)"named events: iterator is NULL %d\n",
               vpi_iterate(vpiNamedEvent, mod) == NULL);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_iterators";
    d.calltf = iterators_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
