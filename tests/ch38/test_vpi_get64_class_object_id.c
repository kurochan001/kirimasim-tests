/* VPI application of test_vpi_get64_class_object_id (IEEE 1800-2023 38.7, 37.33). */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_get64_class_object_id"

/* vpi_get64 takes the property and the handle and returns PLI_INT64; the
   assignment fails to compile as C++ when its type differs. */
static PLI_INT64 (*get64)(PLI_INT32, vpiHandle) = vpi_get64;

static vpiHandle find(const char *name)
{
    char full[160];
    vpiHandle h;
    snprintf(full, sizeof full, "%s.%s", TOP, name);
    h = vpi_handle_by_name((PLI_BYTE8 *)full, NULL);
    if (h == NULL)
        vpi_printf((PLI_BYTE8 *)"%s: not found\n", full);
    return h;
}

static PLI_INT32 ids_calltf(PLI_BYTE8 *user_data)
{
    static int calls = 0;
    vpiHandle a = find("a"), b = find("b"), c = find("c"), n = find("n"), obj;
    PLI_INT64 ia, ib, ic, in, iobj;

    (void)user_data;
    if (a == NULL || b == NULL || c == NULL || n == NULL)
        return 0;
    ia = get64(vpiObjId, a);
    ib = get64(vpiObjId, b);
    ic = get64(vpiObjId, c);
    in = get64(vpiObjId, n);
    calls++;
    if (calls == 1) {
        obj = vpi_handle(vpiClassObj, a);
        iobj = obj != NULL ? get64(vpiObjId, obj) : -1;
        vpi_printf((PLI_BYTE8 *)"PLI_INT64 bytes: %d\n", (int)sizeof(PLI_INT64));
        vpi_printf((PLI_BYTE8 *)"at 1: a nonzero %d, b same as a %d, class obj of a same as a %d,"
                   " c nonzero %d, c differs from a %d, n is 0 %d\n",
                   ia != 0, ib == ia, iobj == ia, ic != 0, ic != ia, in == 0);
    } else {
        vpi_printf((PLI_BYTE8 *)"at 2: b same as c %d, b differs from a %d, a nonzero %d,"
                   " n is 0 %d\n", ib == ic, ib != ia, ia != 0, in == 0);
    }
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data d;
    memset(&d, 0, sizeof d);
    d.type = vpiSysTask;
    d.tfname = (PLI_BYTE8 *)"$vt_ids";
    d.calltf = ids_calltf;
    vpi_register_systf(&d);
}

void (*vlog_startup_routines[])(void) = {register_all, 0};

#ifdef __cplusplus
}
#endif
