#include <cstdio>
#include <cstring>
#include "svdpi.h"
#include "verilated.h"
#include "verilated_vpi.h"
#include "Vt.h"
#include "Vt__Dpi.h"

static bool without_scope;
static bool callback_ran;

static PLI_INT32 select_export_scope(p_cb_data)
{
    svScope first = svGetScopeFromName("TOP.test_dpi_vpi_callback_selects_export_scope.first");
    svScope second = svGetScopeFromName("TOP.test_dpi_vpi_callback_selects_export_scope.second");
    if (!first || !second || first == second) {
        std::puts("callback scope handles unavailable");
        return 0;
    }
    const svScope initial = svGetScope();
    std::printf("callback initial scope=%d\n", initial != nullptr);
    std::fflush(stdout);
    if (without_scope) {
        std::fputs("calling export without setting scope\n", stderr);
        const int result = read_scope_token();
        std::printf("unscoped=%d\n", result);
    } else {
        svSetScope(first);
        const int first_value = read_scope_token();
        svSetScope(second);
        const int second_value = read_scope_token();
        std::printf("callback scopes=%d,%d\n", first_value, second_value);
    }
    callback_ran = true;
    return 0;
}

int main(int argc, char **argv)
{
    without_scope = argc > 1 && std::strcmp(argv[1], "--without-scope") == 0;
    VerilatedContext context;
    context.commandArgs(argc, argv);
    Vt design{&context, "TOP"};
    s_cb_data registration{};
    registration.reason = cbStartOfSimulation;
    registration.cb_rtn = select_export_scope;
    const vpiHandle callback = vpi_register_cb(&registration);
    if (!callback)
        return 2;
    VerilatedVpi::callCbs(cbStartOfSimulation);
    vpi_release_handle(callback);
    design.eval();
    design.final();
    return callback_ran ? 0 : 3;
}
