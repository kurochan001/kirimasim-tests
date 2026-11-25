#include <cstdio>

namespace {
struct OptionalObject {
    OptionalObject()
    {
        std::puts("optional object initialized");
    }
};

OptionalObject optional_object;
}

extern "C" void annex_j_unreferenced_entry()
{
    std::puts("unreferenced entry called");
}
