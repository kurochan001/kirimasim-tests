#include <stddef.h>
#include "sv_vpi_user.h"

#ifdef __cplusplus
extern "C" {
#endif

#define TOP "test_vpi_simulated_net_is_shared_across_interconnect_merges"

static int same(vpiHandle a, vpiHandle b)
{
    return a != NULL && b != NULL && vpi_compare_objects(a, b);
}

static vpiHandle original(const char *path)
{
    return vpi_handle_by_name((PLI_BYTE8 *)path, NULL);
}

static vpiHandle simulation(vpiHandle net)
{
    return net != NULL ? vpi_handle(vpiSimNet, net) : NULL;
}

static vpiHandle probe(const char *label, const char *parent,
                       const char *bridge, const char *driver)
{
    vpiHandle root = original(parent), middle = original(bridge), leaf = original(driver);
    vpiHandle r = simulation(root), m = simulation(middle), l = simulation(leaf);
    vpi_printf("%s original=%d%d%d simulated=%d%d%d common=%d\n",
               label, root != NULL, middle != NULL, leaf != NULL,
               r != NULL, m != NULL, l != NULL, same(r, m) && same(r, l));
    return r;
}

static PLI_INT32 inspect(PLI_BYTE8 *unused)
{
    (void)unused;
    vpiHandle left = probe("left", TOP ".left_net", TOP ".left_a.link", TOP ".left_a.drive.bus");
    vpiHandle right =
        probe("right", TOP ".right_net", TOP ".right_a.link", TOP ".right_a.drive.bus");
    vpi_printf("separate simulations=%d\n", left != NULL && right != NULL && !same(left, right));
    return 0;
}

static void setup(void)
{
    s_vpi_systf_data definition = {0};
    definition.type = vpiSysTask;
    definition.tfname = "$vt_simulated_nets";
    definition.calltf = inspect;
    vpi_register_systf(&definition);
}

void (*vlog_startup_routines[])(void) = {setup, NULL};

#ifdef __cplusplus
}
#endif
