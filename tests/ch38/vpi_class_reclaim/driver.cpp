#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <list>
#include <unordered_map>
#include <vector>

#include "Vreclaim.h"
#include "Vreclaim___024root.h"
#include "Vreclaim___024unit__03a__03areclaim_peer__Vclpkg.h"
#include "Vreclaim___024unit__03a__03areclaim_record__Vclpkg.h"
#include "client.h"

using Record = Vreclaim___024unit__03a__03areclaim_record;

enum class Kind { typespec, variable, object, member, element, method, callback };

struct Handle {
    Kind kind;
    const VlClass *owner;
    unsigned class_type;
    PLI_INT64 id;
    const void *storage;
};

struct Subscription {
    s_cb_data request;
    unsigned class_type;
    const VlClass *owner;
};

static std::list<PLI_UINT32> tokens;
static std::unordered_map<vpiHandle, Handle> handles;
static std::unordered_map<unsigned, vpiHandle> objects;
static std::vector<Subscription> subscriptions;
static int type_deliveries, object_deliveries, end_deliveries;
static bool observing = true;

static void require(bool condition, const char *message)
{
    if (!condition) {
        std::fprintf(stderr, "%s\n", message);
        std::abort();
    }
}

static vpiHandle make_handle(Kind kind, const VlClass *owner, unsigned class_type,
                             PLI_INT64 id = 0, const void *storage = nullptr)
{
    // Unreused token addresses let the table be inspected without using expired VPI handles.
    tokens.push_back(0);
    vpiHandle key = reinterpret_cast<vpiHandle>(&tokens.back());
    require(handles.emplace(key, Handle{kind, owner, class_type, id, storage}).second, "duplicate handle token");
    return key;
}

static vpiHandle subscribe(const s_cb_data &request)
{
    const auto found = handles.find(request.obj);
    if (found == handles.end())
        return nullptr;
    const Handle &target = found->second;
    const bool type = target.kind == Kind::typespec;
    const bool object = target.kind == Kind::object;
    if ((request.reason == cbCreateObj && !type) ||
        (request.reason == cbReclaimObj && !(type || object)) ||
        (request.reason == cbEndOfObject && !object) ||
        (request.reason == cbValueChange && !(target.kind == Kind::member || target.kind == Kind::element)))
        return nullptr;
    subscriptions.push_back({request, target.class_type, target.owner});
    return make_handle(Kind::callback, target.owner, target.class_type);
}

static const Handle &live_object(vpiHandle handle)
{
    const Handle &state = handles.at(handle);
    require(state.kind == Kind::object && state.owner != nullptr, "class object property needs a live object");
    return state;
}

static PLI_INT32 read_property(PLI_INT32 property, vpiHandle object)
{
    (void)live_object(object);
    switch (property) {
    case vpiType: return vpiClassObj;
    case vpiAllocScheme: return vpiDynamicScheme;
    case vpiAutomatic: return 1;
    case vpiIsProtected: return 0;
    default: return vpiUndefined;
    }
}

static PLI_INT64 read_id(PLI_INT32 property, vpiHandle object)
{
    return property == vpiObjId ? live_object(object).id : vpiUndefined;
}

static unsigned serial_of(vpiHandle object)
{
    // The ID separates object identity from the small HDL fixture value.
    return static_cast<unsigned>(live_object(object).id - 0x100000000LL);
}

static PLI_INT32 report_callback(p_cb_data data)
{
    const reclaim_observation event = observe_callback(data, read_property, read_id);
    require(event.typed && event.dynamic && event.automatic_storage && event.clear && event.id > 0xffffffffLL,
            "class object properties unavailable during callback");
    if (event.reason == cbCreateObj) {
        std::printf("create serial=%u class=%d id64=%d\n", serial_of(data->obj), event.typed, event.id > 0xffffffffLL);
        return 0;
    }
    const char *watcher = data->user_data;
    require(event.no_time && (event.reason == cbReclaimObj || event.reason == cbEndOfObject),
            "invalid class collection callback payload");
    if (event.reason == cbEndOfObject)
        ++end_deliveries;
    else if (std::strcmp(watcher, "type") == 0)
        ++type_deliveries;
    else
        ++object_deliveries;
    std::printf("callback %s serial=%u no-time=%d class=%d dynamic=%d auto=%d clear=%d id64=%d\n",
                watcher, serial_of(data->obj), event.no_time, event.typed, event.dynamic,
                event.automatic_storage, event.clear, event.id > 0xffffffffLL);
    return 0;
}

static void deliver(PLI_INT32 reason, const Handle &object, vpiHandle token)
{
    for (const Subscription &subscription : subscriptions) {
        if (subscription.request.reason == reason && subscription.class_type == object.class_type &&
            (subscription.owner == nullptr || subscription.owner == object.owner)) {
            s_cb_data delivered = subscription.request;
            delivered.obj = token;
            delivered.time = nullptr;
            delivered.cb_rtn(&delivered);
        }
    }
}

static vpiHandle register_callback(PLI_INT32 reason, vpiHandle target, const char *label)
{
    static s_vpi_time time = {vpiSimTime, 0, 0, 0.0};
    s_cb_data request = {};
    request.reason = reason;
    request.obj = target;
    request.cb_rtn = report_callback;
    request.time = &time;
    request.user_data = const_cast<PLI_BYTE8 *>(label);
    return subscribe(request);
}

struct RelatedHandles {
    vpiHandle object, member, element;
};

static RelatedHandles bind_object(const VlClass *object, unsigned serial, unsigned class_type)
{
    require(object != nullptr && object->refCount() > 0, "expected a constructed HDL object");
    const PLI_INT64 id = 0x100000000LL + serial;
    vpiHandle token = make_handle(Kind::object, object, class_type, id);
    RelatedHandles related = {token, nullptr, nullptr};
    make_handle(Kind::object, object, class_type, id);
    if (class_type == 1) {
        const auto *record = dynamic_cast<const Record *>(object);
        require(record != nullptr && record->__PVT__values[1] == serial + 3, "native member/subelement mismatch");
        related.member = make_handle(Kind::member, object, class_type, 0, &record->__PVT__serial);
        make_handle(Kind::member, object, class_type, 0, &record->__PVT__values);
        related.element = make_handle(Kind::element, object, class_type, 0, &record->__PVT__values[1]);
        make_handle(Kind::method, object, class_type);
    }
    require(objects.emplace(serial, token).second, "duplicate object identity");
    const Handle state = handles.at(token);
    deliver(cbCreateObj, state, token);
    return related;
}

void observe_class_destruction(const VlClass *object, unsigned serial)
{
    const vpiHandle token = objects.at(serial);
    const Handle state = handles.at(token);
    require(state.owner == object && object->refCount() == 0, "expected actual native collection at refcount zero");
    std::vector<vpiHandle> owned;
    unsigned kind_counts[static_cast<unsigned>(Kind::callback) + 1] = {};
    for (const auto &entry : handles) {
        if (entry.second.owner != object)
            continue;
        const Kind kind = entry.second.kind;
        owned.push_back(entry.first);
        ++kind_counts[static_cast<unsigned>(kind)];
        if (kind == Kind::member || kind == Kind::element)
            require(entry.second.storage != nullptr, "no backing storage for an automatic object subhandle");
    }
    if (observing) {
        std::printf("reclaim serial=%u objects=%u members=%u elements=%u methods=%u callbacks=%u\n", serial,
                    kind_counts[static_cast<unsigned>(Kind::object)], kind_counts[static_cast<unsigned>(Kind::member)],
                    kind_counts[static_cast<unsigned>(Kind::element)], kind_counts[static_cast<unsigned>(Kind::method)],
                    kind_counts[static_cast<unsigned>(Kind::callback)]);
        deliver(cbReclaimObj, state, token);
        deliver(cbEndOfObject, state, token);
    }
    for (vpiHandle handle : owned)
        handles.erase(handle);
    objects.erase(serial);
    subscriptions.erase(std::remove_if(subscriptions.begin(), subscriptions.end(),
                                       [object](const Subscription &entry) { return entry.owner == object; }),
                        subscriptions.end());
    // This is private table inspection. The application never calls VPI on a removed handle.
    const auto remaining = std::count_if(owned.begin(), owned.end(), [](vpiHandle key) { return handles.count(key); });
    if (observing)
        std::printf("after serial=%u retired=%zu remaining=%zu\n", serial, owned.size(), static_cast<size_t>(remaining));
    require(remaining == 0, "object-specific handles remained after collection");
}

int main(int argc, char **argv)
{
    const bool hold_first = argc == 2 && std::strcmp(argv[1], "--hold-first") == 0;
    VerilatedContext context;
    Vreclaim model{&context};
    auto &roots = model.rootp->__Vnontrivs;
    auto &first = roots.test_vpi_class_reclaim_lifetimes__DOT__first;
    auto &second = roots.test_vpi_class_reclaim_lifetimes__DOT__second;
    auto &other = roots.test_vpi_class_reclaim_lifetimes__DOT__other;
    const vpiHandle typespec = make_handle(Kind::typespec, nullptr, 1);
    const vpiHandle variable = make_handle(Kind::variable, nullptr, 1);
    const vpiHandle create = register_callback(cbCreateObj, typespec, "create");
    const vpiHandle reclaim = register_callback(cbReclaimObj, typespec, "type");
    const bool variable_rejected = register_callback(cbReclaimObj, variable, "wrong") == nullptr;
    std::printf("registrations create-type=%d reclaim-type=%d variable-rejected=%d\n",
                create != nullptr, reclaim != nullptr, variable_rejected);
    model.eval();
    require(first && second && other, "initial HDL objects missing");
    const RelatedHandles watched = bind_object(first.operator->(), first->__PVT__serial, 1);
    bind_object(second.operator->(), second->__PVT__serial, 1);
    bind_object(other.operator->(), other->__PVT__serial, 2);
    const vpiHandle direct = register_callback(cbReclaimObj, watched.object, "object");
    const vpiHandle ended = register_callback(cbEndOfObject, watched.object, "end");
    const bool create_rejected = register_callback(cbCreateObj, watched.object, "wrong") == nullptr;
    std::printf("object registrations reclaim=%d end=%d create-rejected=%d\n",
                direct != nullptr, ended != nullptr, create_rejected);
    const vpiHandle member_watch = register_callback(cbValueChange, watched.member, "member");
    const vpiHandle element_watch = register_callback(cbValueChange, watched.element, "element");
    std::printf("member registrations property=%d element=%d\n", member_watch != nullptr, element_watch != nullptr);
    VlClassRef<Record> retained;
    if (hold_first)
        retained = first;
    for (int step = 1; step <= 4; ++step) {
        context.timeInc(1000);
        model.eval();
    }
    require(context.gotFinish(), "the HDL run did not complete");
    std::printf("counts type=%d object=%d end=%d first-live=%d type-handle=%d type-callback=%d\n",
                type_deliveries, object_deliveries, end_deliveries, objects.count(29) != 0,
                handles.count(typespec) != 0, handles.count(reclaim) != 0);
    observing = false;
    model.final();
}
