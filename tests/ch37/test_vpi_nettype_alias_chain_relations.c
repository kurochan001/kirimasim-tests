#include <stdio.h>
#include <string.h>
#include "vpi_user.h"
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

static PLI_INT32 aliases(PLI_BYTE8 *data)
{
    vpiHandle top = vpi_handle_by_name((PLI_BYTE8 *)"test_vpi_nettype_alias_chain_relations", NULL);
    vpiHandle it = top ? vpi_iterate(vpiNettypeDecl, top) : NULL, h;
    vpiHandle root = NULL, first = NULL, second = NULL, resolver;
    char name[64];
    (void)data;
    while (it && (h = vpi_scan(it)) != NULL) {
        const char *s = vpi_get_str(vpiName, h);
        snprintf(name, sizeof name, "%s", s ? s : "");
        if (!strcmp(name, "root_type")) root = h;
        if (!strcmp(name, "first_alias")) first = h;
        if (!strcmp(name, "second_alias")) second = h;
    }
    resolver = root ? vpi_handle(vpiWith, root) : NULL;
    vpi_printf("alias_links=%d,%d resolver=%d\n",
        root && first && vpi_compare_objects(vpi_handle(vpiNetTypedefAlias, first), root),
        first && second && vpi_compare_objects(vpi_handle(vpiNetTypedefAlias, second), first),
        resolver != NULL && vpi_get(vpiType, resolver) == vpiFunction);
    return 0;
}

static void register_all(void)
{
    s_vpi_systf_data tf;
    memset(&tf, 0, sizeof tf);
    tf.type = vpiSysTask; tf.tfname = (PLI_BYTE8 *)"$depth_aliases"; tf.calltf = aliases;
    vpi_register_systf(&tf);

}
void (*vlog_startup_routines[])(void) = {register_all, 0};
#ifdef __cplusplus
}
#endif
