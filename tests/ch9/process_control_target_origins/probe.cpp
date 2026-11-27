#include <array>
#include <cstdio>
#include <map>
#include <string>
#include <string_view>
#include <sukimasim/ir/process_class.h>
#include <sukimasim/vpi/sv_vpi_user.h>

#include "origins.h"

using sukimasim::ir::ProcessClassValue;
using Process = std::shared_ptr<ProcessClassValue>;
static std::map<std::string, Process> observed;

static PLI_INT32 observe_process(PLI_BYTE8 *)
{
    vpiHandle arguments = vpi_iterate(vpiArgument, vpi_handle(vpiSysTfCall, nullptr));
    vpiHandle label = arguments ? vpi_scan(arguments) : nullptr;
    if (!label) return 0;

    s_vpi_value value{};
    value.format = vpiStringVal;
    vpi_get_value(label, &value);
    if (!value.value.str || !observed.emplace(value.value.str, ProcessClassValue::self()).second)
        std::puts("origin capture failed");
    vpi_release_handle(arguments);
    return 0;
}

using Action = void (ProcessClassValue::*)();
struct Operation {
    const char *name;
    Action action;
};
static constexpr std::array methods{
    Operation{"await", &ProcessClassValue::await},
    Operation{"suspend", &ProcessClassValue::suspend},
    Operation{"resume", &ProcessClassValue::resume},
    Operation{"kill", &ProcessClassValue::kill},
};

static void control_final(const Process &target, bool allowed)
{
    auto &manager = sukimasim::ir::ProcessManager::getInstance();
    Process previous = manager.getCurrentProcess();
    Process controller = observed.at("controller");
    manager.setCurrentProcess(controller);
    std::printf("caller distinct=%d\n", manager.getCurrentProcess() != target);

    for (const Operation &method : methods) {
        if (!allowed) {
            std::printf("%s rejected: excluded process origin\n", method.name);
            continue;
        }
        try {
            ((*target).*method.action)();
            std::printf("%s reached target state=%d\n", method.name, target->getStatus());
        } catch (const sukimasim::ir::AwaitSuspendException &error) {
            std::printf("%s reached target would-block=%d\n", method.name, error.getTargetProcess() == target);
        }
    }
    manager.setCurrentProcess(previous);
}

static PLI_INT32 after_final(p_cb_data)
{
    if (observed.size() != std::size(origins)) {
        std::puts("origin count mismatch");
        observed.clear();
        return 0;
    }

    std::map<int, bool> permitted_by_id;
    Process excluded;
    for (const Origin &origin : origins) {
        const auto target = observed.find(origin.name);
        if (target == observed.end()) {
            std::puts("missing captured process");
            break;
        }
        const Process &process = target->second;
        const int id = process->getProcessId();
        const bool fork = std::string_view(origin.kind) == "Fork";
        const int parent = fork ? observed.at(origin.parent)->getProcessId() : 0;
        if (process->getParentProcessId() != parent || permitted_by_id.contains(id)) {
            std::puts("runtime identity or fork parent mismatch");
            break;
        }
        const std::string_view kind(origin.kind);
        const bool permitted = fork ? permitted_by_id.at(parent) : kind == "Initial" || kind == "Always";
        permitted_by_id.emplace(id, permitted);
        std::printf("origin %s kind=%s parent=%s permit=%d\n", origin.name, origin.kind, origin.parent, permitted);
        if (kind == "Final") excluded = process;
    }

    if (excluded && permitted_by_id.size() == observed.size()) {
        const auto before = excluded->getStatus();
#ifdef BYPASS_ORIGIN_GUARD
        control_final(excluded, true);
#else
        control_final(excluded, permitted_by_id.at(excluded->getProcessId()));
#endif
        std::printf("final state unchanged=%d\n", excluded->getStatus() == before);
    }
    observed.clear();
    return 0;
}

static void install()
{
    s_vpi_systf_data task{};
    task.type = vpiSysTask;
    task.tfname = (PLI_BYTE8 *)"$observe_process";
    task.calltf = observe_process;
    vpi_register_systf(&task);
    s_cb_data callback{};
    callback.reason = cbEndOfSimulation;
    callback.cb_rtn = after_final;
    vpi_register_cb(&callback);
}

extern "C" {
void (*vlog_startup_routines[])(void) = {install, nullptr};
}
