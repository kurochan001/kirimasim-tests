#include <cstdio>
#include <sukimasim/scheduler/full_delta_scheduler.h>
#include <sukimasim/vpi/vpi_user.h>

using namespace sukimasim::scheduler;

static PLI_INT32 probe(PLI_BYTE8*)
{
    FullDeltaScheduler scheduler;
    int p = 0;
    int mark = 0;
    scheduler.scheduleEvent(std::make_shared<PreReNBAEvent>([&] {
        std::printf("pre p=%d\n", p);
        mark = 31;
        scheduler.scheduleEvent(std::make_shared<ReActiveEvent>([&] {
            std::printf("reactive before p=%d mark=%d\n", p, mark);
        }));
        scheduler.scheduleEvent(std::make_shared<ActiveFullEvent>([&] {
            std::printf("active from pre p=%d mark=%d\n", p, mark);
        }));
    }));
    scheduler.scheduleEvent(std::make_shared<ReNBAEvent>([&] {
        p = 5;
        std::printf("update p=%d\n", p);
    }));
    scheduler.scheduleEvent(std::make_shared<PostReNBAEvent>([&] {
        std::printf("post p=%d mark=%d\n", p, mark);
        mark = 47;
        scheduler.scheduleEvent(std::make_shared<ReActiveEvent>([&] {
            std::printf("reactive after p=%d mark=%d\n", p, mark);
        }));
        scheduler.scheduleEvent(std::make_shared<ActiveFullEvent>([&] {
            std::printf("active from post p=%d mark=%d\n", p, mark);
        }));
    }));
    for (int cycle = 0; cycle < 8 && scheduler.hasPendingEvents(); ++cycle)
        scheduler.executeDeltaCycle();
    return 0;
}

static void install()
{
    s_vpi_systf_data task = {};
    task.type = vpiSysTask;
    task.tfname = const_cast<PLI_BYTE8*>("$probe_re_nba_regions");
    task.calltf = probe;
    vpi_register_systf(&task);
}

extern "C" {
void (*vlog_startup_routines[])(void) = {install, nullptr};
}
