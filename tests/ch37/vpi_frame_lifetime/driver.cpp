#include "Vframe_life.h"
#include "Vframe_life__Dpi.h"
#include "verilated.h"
#include "vpi_user.h"
#include "sv_vpi_user.h"

#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <list>
#include <memory>
#include <set>

namespace {

void require(bool condition, const char *message) {
    if (!condition) {
        std::fprintf(stderr, "%s\n", message);
        std::abort();
    }
}

struct Handles {
    PLI_UINT32 thread = 0, frame = 0, stamp = 0, vector = 0, bit = 0;
};

struct Activation {
    Handles tokens;
    const VlProcess *process = nullptr;
    const uint32_t *stamp = nullptr;
    const uint8_t *vector = nullptr;
    bool body_started = false, body_finished = false;
};

struct Subscription {
    s_cb_data data;
    PLI_UINT32 token = 0;
};

std::array<Activation, 2> branches;
std::set<vpiHandle> handles;
std::list<Subscription> subscriptions;
VerilatedContext *clock_context = nullptr;

Activation &owner(uint32_t branch) { return branches.at(branch); }

const Activation &owner(vpiHandle object) {
    for (const auto &activation : branches) {
        auto &tokens = activation.tokens;
        if (object == &tokens.thread || object == &tokens.frame ||
            object == &tokens.stamp || object == &tokens.vector || object == &tokens.bit)
            return activation;
    }
    std::abort();
}

PLI_INT32 type(vpiHandle object) {
    require(handles.count(object) == 1, "callback accessed an inactive handle");
    const auto &tokens = owner(object).tokens;
    if (object == &tokens.thread) return vpiThread;
    if (object == &tokens.frame) return vpiFrame;
    if (object == &tokens.stamp) return vpiIntVar;
    if (object == &tokens.vector) return vpiByteVar;
    return vpiBitSelect;
}

PLI_INT32 read(vpiHandle object) {
    const PLI_INT32 kind = type(object);
    const auto &activation = owner(object);
    if (kind == vpiIntVar) return static_cast<PLI_INT32>(*activation.stamp);
    if (kind == vpiByteVar) return *activation.vector;
    require(kind == vpiBitSelect, "expected a local variable or its bit");
    return (*activation.vector >> 4) & 1U;
}

vpiHandle subscribe(s_cb_data data) {
    const PLI_INT32 kind = type(data.obj);
    if (data.reason != cbEndOfObject && (data.time == nullptr || data.time->type != vpiSimTime))
        return nullptr;
    switch (data.reason) {
    case cbStartOfFrame:
    case cbEndOfFrame:
        if (kind != vpiFrame) return nullptr;
        break;
    case cbStartOfThread:
    case cbEndOfThread:
        if (kind != vpiThread) return nullptr;
        break;
    case cbEndOfObject:
        if (kind != vpiFrame && kind != vpiThread) return nullptr;
        break;
    default:
        return nullptr;
    }
    subscriptions.push_back({data, 0});
    return &subscriptions.back().token;
}

PLI_INT32 observe(s_cb_data *event) {
    const auto &activation = owner(event->obj);
    const auto branch = static_cast<unsigned>(&activation - branches.data());
    const auto kind = type(event->obj);
    const bool object_end = event->reason == cbEndOfObject;
    require(object_end == (event->time == nullptr), "unexpected callback time field");
    if (!object_end) {
        const auto time = (uint64_t{event->time->high} << 32) | event->time->low;
        require(event->time->type == vpiSimTime && time == clock_context->time(), "wrong callback time");
    }
    if (kind == vpiFrame) {
        auto &tokens = owner(branch).tokens;
        const bool starting = event->reason == cbStartOfFrame;
        require(starting ? !activation.body_started : activation.body_finished, "wrong frame callback order");
        require(activation.process == VlProcess::currentp(), "callback ran outside the owning thread");
        std::printf("callback %s frame branch=%u stamp=%d vector=%d bit=%d\n",
                    starting ? "start" : object_end ? "end-object" : "end", branch,
                    read(&tokens.stamp), read(&tokens.vector), read(&tokens.bit));
    } else {
        require(kind == vpiThread && activation.process != nullptr, "missing thread");
        const bool starting = event->reason == cbStartOfThread;
        require(activation.stamp == nullptr && activation.vector == nullptr, "thread callback saw a live frame");
        require(starting ? !activation.body_started : activation.body_finished, "wrong thread callback order");
        require(starting ? activation.process->state() == VlProcess::RUNNING
                         : activation.process->completed(), "unexpected native thread state");
        std::printf("callback %s thread branch=%u\n", starting ? "start" : object_end ? "end-object" : "end", branch);
    }
    return 0;
}

void watch(vpiHandle object, PLI_INT32 start, PLI_INT32 end, PLI_INT32 wrong_start) {
    static s_vpi_time time{vpiSimTime, 0, 0, 0.0};
    s_cb_data data{};
    data.obj = object;
    data.cb_rtn = observe;
    for (PLI_INT32 reason : {start, end, PLI_INT32{cbEndOfObject}}) {
        data.reason = reason;
        data.time = reason == cbEndOfObject ? nullptr : &time;
        require(subscribe(data) != nullptr, "eligible callback registration rejected");
    }
    data.reason = wrong_start;
    data.time = &time;
    require(subscribe(data) == nullptr, "callback accepted the wrong transient object type");
}

void deliver(vpiHandle object, PLI_INT32 reason) {
    const auto ticks = clock_context->time();
    s_vpi_time time{vpiSimTime, static_cast<PLI_UINT32>(ticks >> 32), static_cast<PLI_UINT32>(ticks), 0.0};
    unsigned calls = 0;
    for (const auto &subscription : subscriptions) {
        if (subscription.data.obj != object || subscription.data.reason != reason)
            continue;
        auto event = subscription.data;
        event.time = reason == cbEndOfObject ? nullptr : &time;
        event.cb_rtn(&event);
        ++calls;
    }
    require(calls == 1, "missing or duplicate callback");
}

void retire(vpiHandle object, std::initializer_list<vpiHandle> related) {
    unsigned callbacks = 0;
    subscriptions.remove_if([&](const Subscription &entry) {
        if (entry.data.obj != object)
            return false;
        ++callbacks;
        return true;
    });
    require(callbacks == 3, "object callbacks were removed too early");
    require(handles.erase(object) == 1, "object was removed too early");
    for (vpiHandle handle : related)
        require(handles.erase(handle) == 1, "object subhandle was removed too early");
    require(handles.count(object) == 0, "ended object still live");
    for (vpiHandle handle : related)
        require(handles.count(handle) == 0, "ended object subhandle still live");
}

}  // namespace

std::shared_ptr<VlProcess> observed_child_process(const VlProcessRef &parent, unsigned branch) {
    auto process = std::shared_ptr<VlProcess>(new VlProcess(parent), [branch](VlProcess *ended) {
        auto &activation = owner(branch);
        const auto token = &activation.tokens.thread;
        require(activation.process == ended && handles.count(&activation.tokens.frame) == 0,
                "thread retired before its frame or with the wrong identity");
        deliver(token, cbEndOfThread);
        deliver(token, cbEndOfObject);
        retire(token, {});
        activation.process = nullptr;
        delete ended;
    });
    auto &activation = owner(branch);
    activation.process = process.get();
    const auto token = &activation.tokens.thread;
    require(handles.insert(token).second, "duplicate thread handle");
    watch(token, cbStartOfThread, cbEndOfThread, cbStartOfFrame);
    deliver(token, cbStartOfThread);
    return process;
}

void enter_frame(unsigned branch, const uint32_t *stamp, const uint8_t *vector) {
    auto &activation = owner(branch);
    require(activation.process != nullptr && activation.process == VlProcess::currentp(),
            "frame does not belong to the current thread");
    require(!activation.stamp && !activation.vector, "duplicate frame activation");
    activation.stamp = stamp;
    activation.vector = vector;
    auto &tokens = activation.tokens;
    for (vpiHandle handle : {&tokens.frame, &tokens.stamp, &tokens.vector, &tokens.bit})
        require(handles.insert(handle).second, "duplicate frame handle");
    watch(&tokens.frame, cbStartOfFrame, cbEndOfFrame, cbStartOfThread);
    deliver(&tokens.frame, cbStartOfFrame);
}

void leave_frame(unsigned branch) {
    auto &activation = owner(branch);
    auto &tokens = activation.tokens;
    deliver(&tokens.frame, cbEndOfFrame);
    deliver(&tokens.frame, cbEndOfObject);
    retire(&tokens.frame, {&tokens.stamp, &tokens.vector, &tokens.bit});
    activation.stamp = nullptr;
    activation.vector = nullptr;
    require(handles.count(&tokens.thread) == 1, "exiting frame invalidated its still-live thread");
}

extern "C" void observe_body(int branch, int stamp, char vector, svBit leaving) {
    auto &activation = owner(static_cast<unsigned>(branch));
    auto &tokens = activation.tokens;
    require(activation.body_started == (leaving != 0) && !activation.body_finished,
            "task body observations are out of order");
    require(read(&tokens.stamp) == stamp && read(&tokens.vector) == static_cast<unsigned char>(vector),
            "VPI handles do not view the generated task's actual locals");
    activation.body_started = true;
    activation.body_finished = leaving != 0;
}

extern "C" void observe_phase(int phase) {
    std::printf("registry phase=%d", phase);
    for (auto &activation : branches) {
        auto &tokens = activation.tokens;
        const auto local_count = handles.count(&tokens.stamp) + handles.count(&tokens.vector) +
                                 handles.count(&tokens.bit);
        std::printf(" %zu/%zu/%zu", handles.count(&tokens.thread), handles.count(&tokens.frame), local_count);
        if (local_count != 0) {
            require(local_count == 3 && handles.count(&tokens.frame) == 1, "partial live frame");
            std::printf(":%d/%d/%d", read(&tokens.stamp), read(&tokens.vector), read(&tokens.bit));
        }
    }
    std::printf(" callbacks=%zu\n", subscriptions.size());
}

int main() {
    VerilatedContext context;
    clock_context = &context;
    Vframe_life top{&context};
    while (!context.gotFinish()) {
        top.eval();
        if (!top.eventsPending()) break;
        context.time(top.nextTimeSlot());
    }
    top.final();
    require(context.gotFinish() && handles.empty() && subscriptions.empty(), "transient handles survived the fixture");
}
