#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <unordered_map>

#include "Vweak.h"
#include "Vweak__Dpi.h"
#include "Vweak___024unit__03a__03aweak_gc_payload__Vclpkg.h"
#include "Vweak___024unit__03a__03aweak_gc_view__Vclpkg.h"
#include "Vweak_test_weak_reference_reclamation.h"

using Payload = Vweak___024unit__03a__03aweak_gc_payload;

struct Referent {
    Referent(Payload *value, long long identifier) : pointer(value), id(identifier) {}

    std::atomic<Payload *> pointer;
    const long long id;
};

static std::unordered_map<int, std::shared_ptr<Referent>> live;
static std::unordered_map<int, std::shared_ptr<Referent>> views;
static int next_slot = 1, retired_slot;
static long long next_id = 1, reusable_id;
static unsigned target_destructions, early_wrapper_destructions;
static bool observing = true;

static void require(bool condition, const char *message)
{
    if (!condition) {
        std::fprintf(stderr, "%s\n", message);
        std::abort();
    }
}

static void attach(Payload *object)
{
    require(object != nullptr, "payload was not constructed");
    const long long id = reusable_id != 0 ? reusable_id : next_id++;
    reusable_id = 0;
    require(live.emplace(object->__PVT__serial, std::make_shared<Referent>(object, id)).second,
            "payload serial already registered");
}

extern "C" int make_weak_view(int serial)
{
    const int slot = next_slot++;
    views.emplace(slot, live.at(serial));
    return slot;
}

extern "C" int read_weak_view(int slot)
{
    Payload *value = views.at(slot)->pointer.load();
    return value == nullptr ? -1 : static_cast<int>(value->__PVT__serial);
}

extern "C" long long weak_numeric_id(int serial)
{
    return live.at(serial)->id;
}

static unsigned slots_for(const std::shared_ptr<Referent> &referent)
{
    unsigned count = 0;
    for (const auto &entry : views)
        count += entry.second == referent;
    return count;
}

/* Called by the generated SystemVerilog destructors at actual collection. */
void weak_observe_payload_destruction(const VlClass *object, unsigned serial)
{
    auto entry = live.find(static_cast<int>(serial));
    require(entry != live.end() && object->refCount() == 0, "unexpected payload collection");
    const auto state = entry->second;
    // Every live wrapper for this object reads the same atomic slot.
    require(state->pointer.exchange(nullptr) == object, "collection did not clear the registered payload");
    live.erase(entry);
    if (observing && serial == 29) {
        ++target_destructions;
        reusable_id = state->id;
        std::printf("destroy target strong=%zu cleared=%u peer-alive=%d\n",
                    object->refCount(), slots_for(state), live.at(47)->pointer.load() != nullptr);
    }
}

void weak_observe_view_destruction(const VlClass *object, unsigned slot)
{
    const auto entry = views.find(static_cast<int>(slot));
    require(entry != views.end() && object->refCount() == 0, "unexpected wrapper collection");
    if (observing && static_cast<int>(slot) == retired_slot) {
        ++early_wrapper_destructions;
        const Payload *referent = entry->second->pointer.load();
        std::printf("destroy wrapper strong=%zu target-alive=%d\n",
                    object->refCount(), referent != nullptr && referent->refCount() > 0);
    }
    views.erase(entry);
}

int main(int argc, char **argv)
{
    const bool keep_strong = argc == 2 && std::strcmp(argv[1], "--keep-strong") == 0;
    VerilatedContext context;
    Vweak model{&context};
    model.eval();
    auto &roots = model.__PVT__test_weak_reference_reclamation->__Vnontrivs;
    auto &owner = roots.owner;
    auto &peer = roots.peer;
    auto &replacement = roots.replacement;
    auto &retired = roots.retired;
    require(owner && peer, "initial payloads are missing");
    attach(owner.operator->());
    attach(peer.operator->());
    VlClassRef<Payload> held;
    if (keep_strong)
        held = owner;

    const auto target = live.at(29);
    const auto control = live.at(47);
    for (int step = 1; step <= 7; ++step) {
        context.timeInc(1000);
        model.eval();
        if (step == 1) {
            require(static_cast<bool>(retired), "the early wrapper is missing");
            retired_slot = static_cast<int>(retired->__PVT__slot);
            std::printf("after weak views strong=%zu,%zu slots=%u,%u\n", owner->refCount(), peer->refCount(),
                        slots_for(target), slots_for(control));
        }
        if (step == 4) {
            Payload *pending = target->pointer.load();
            require(!owner && pending != nullptr && early_wrapper_destructions == 1, "unexpected reachability state");
            int values[2] = {};
            unsigned remaining = 0;
            for (const auto &entry : views) {
                if (entry.second == target) {
                    require(remaining < 2, "extra weak view keeps the target visible");
                    values[remaining++] = read_weak_view(entry.first);
                }
            }
            require(remaining == 2, "both surviving weak views must be observable");
            std::printf("%s strong=%zu left=%d right=%d peer=%u\n", keep_strong ? "strong control" : "weakly reachable",
                        pending->refCount(), values[0], values[1], peer->__PVT__serial);
        }
        if (step == 5)
            attach(replacement.operator->());
    }
    require(context.gotFinish() && target_destructions == (keep_strong ? 0u : 1u), "unexpected collection result");
    observing = false;
    model.final();
}
