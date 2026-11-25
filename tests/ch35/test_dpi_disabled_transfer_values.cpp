#include <cstdio>
#include "svdpi.h"

#ifdef GHOST_DPI_FUNCTION_ACK_PROBE
#include <algorithm>
#include "sukimasim/dpi/dpi_disable_state.h"
#endif

extern "C" int task_stop(int cancel);
extern "C" int function_stop(int cancel);
extern "C" int sv_function_wrapper(int cancel);

extern "C" int task_write(int cancel, int *out, int *io)
{
    int status = task_stop(cancel);
    int disabled = svIsDisabledState();
    *out = cancel ? 201 : 101;
    *io = cancel ? 182 : *io + 50;
    std::printf("C task cancel=%d export=%d disabled=%d out=%d io=%d\n",
                cancel, status, disabled, *out, *io);
    std::fflush(stdout);
    return disabled != 0;
}

extern "C" int function_write(int cancel, int *out, int *io)
{
#ifdef GHOST_DPI_FUNCTION_ACK_PROBE
    // Supply the caller name for this build's function frame before the SV disable.
    if (cancel) {
        if (auto *frame = sukimasim::dpi::currentDpiImportFrame()) {
            auto &names = frame->callerBlockNames;
            if (std::find(names.begin(), names.end(), "function_worker") == names.end()) {
                names.push_back("function_worker");
                std::puts("function caller supplied");
            } else {
                std::puts("function caller existing");
            }
        }
    }
#endif
    function_stop(cancel);
    int disabled = svIsDisabledState();
    *out = cancel ? 202 : 102;
    *io = cancel ? 193 : *io + 51;
    int result = cancel ? 203 : 103;
    std::printf("C function cancel=%d disabled=%d out=%d io=%d value=%d\n",
                cancel, disabled, *out, *io, result);
    if (disabled) {
        svAckDisabledState();
        std::puts("function acknowledged");
    }
    std::fflush(stdout);
    return result;
}

extern "C" int wrap_function(int cancel)
{
    int status = sv_function_wrapper(cancel);
    int disabled = svIsDisabledState();
    std::printf("outer task cancel=%d export=%d disabled=%d\n", cancel, status, disabled);
    std::fflush(stdout);
    return disabled != 0;
}
