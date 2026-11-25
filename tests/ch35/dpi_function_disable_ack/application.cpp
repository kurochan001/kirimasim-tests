#include <cstdio>
#include "svdpi.h"

#ifdef GHOST_DPI_FUNCTION_ACK_PROBE
#include <algorithm>
#include "sukimasim/dpi/dpi_disable_state.h"

// Supply the caller name that this Ghost build tracks only for task imports.
// The exported SV function still executes the disable and the simulator sets the state.
static void track_worker()
{
    auto *frame = sukimasim::dpi::currentDpiImportFrame();
    if (!frame) {
        std::puts("DPI_ACK_TRACKING no import frame");
    } else {
        auto &names = frame->callerBlockNames;
        if (std::find(names.begin(), names.end(), "worker") == names.end()) {
            names.push_back("worker");
            std::puts("DPI_ACK_TRACKING supplied worker");
        } else {
            std::puts("DPI_ACK_TRACKING existing worker");
        }
    }
    std::fflush(stdout);
}
#endif

extern "C" int run_export(int requested);

extern "C" int run_import(int requested, int omit_ack)
{
    std::printf("import request=%d entry-disabled=%d\n", requested, svIsDisabledState());
    std::fflush(stdout);
#ifdef GHOST_DPI_FUNCTION_ACK_PROBE
    if (requested)
        track_worker();
#endif
    int result = run_export(requested);
    int disabled = svIsDisabledState();
    std::printf("export returned disabled=%d\n", disabled);
    if (disabled && !omit_ack) {
        svAckDisabledState();
        std::puts("disabled function acknowledged");
    } else if (disabled) {
        std::puts("disabled function returning without acknowledgement");
    }
    std::fflush(stdout);
    return disabled ? 0 : result;
}
