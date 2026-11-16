#include <chrono>
#include <cstdint>
#include <iostream>
#include <string>
#include <utility>

#include "kirimasim/kernel/context.h"
#include "kirimasim/sir/design.h"
#include "kirimasim/sir/verified.h"
#include "kirimasim/vm/vm.h"

int main(int argc, char** argv) {
    namespace s = kirimasim::sir;
    namespace k = kirimasim::kernel;
    const unsigned functions = argc > 1 ? static_cast<unsigned>(std::stoul(argv[1])) : 1000;
    constexpr unsigned perFunction = 100;
    s::Design design;
    design.sources = {"metadata_load.sv"};
    design.instances = {{"top", "top", s::kNone}};
    design.constants = {{s::u4(65), {1, 0}, {0, 0}}, {s::u4(65), {2, 0}, {0, 0}}};
    s::Process main;
    main.name = "top.initial0";
    main.blocks.resize(1);
    main.blocks[0].instrs.push_back({s::Op::Ret, s::voidType(), s::kNone, {}, {0, 1, 1}});
    design.processes.push_back(std::move(main));
    design.subroutines.reserve(functions);
    for (unsigned f = 0; f < functions; ++f) {
        s::Subroutine sub;
        sub.name = "top.function" + std::to_string(f);
        sub.kind = s::SubroutineKind::Function;
        sub.automatic = true;
        sub.numTemps = perFunction;
        sub.blocks.resize(1);
        auto& instructions = sub.blocks[0].instrs;
        instructions.reserve(perFunction + 1);
        for (unsigned i = 0; i < perFunction; ++i)
            instructions.push_back({s::Op::Add, s::u4(65), s::TempId{i},
                                    {s::Operand::constant(s::ConstId{0}),
                                     s::Operand::constant(s::ConstId{1})}, {0, 1, 1}});
        instructions.push_back({s::Op::Ret, s::voidType(), s::kNone, {}, {0, 1, 1}});
        design.subroutines.push_back(std::move(sub));
    }
    const auto beforeVerify = std::chrono::steady_clock::now();
    auto verified = s::verifyDesign(std::move(design));
    const auto afterVerify = std::chrono::steady_clock::now();
    if (!verified.verified) {
        for (const auto& error : verified.errors)
            std::cerr << error.where << ": " << error.message << '\n';
        return 2;
    }
    k::Context context;
    const auto start = std::chrono::steady_clock::now();
    const auto result = kirimasim::vm::run(*verified.verified, context);
    const auto end = std::chrono::steady_clock::now();
    if (result.reason != k::EndReason::Quiescent) {
        std::cerr << result.error << '\n';
        return 3;
    }
    std::cout << "{\"functions\":" << functions << ",\"instructions\":"
              << functions * (perFunction + 1) + 1
              << ",\"verify_seconds\":"
              << std::chrono::duration<double>(afterVerify-beforeVerify).count()
              << ",\"load_and_empty_run_seconds\":"
              << std::chrono::duration<double>(end-start).count() << "}\n";
}
