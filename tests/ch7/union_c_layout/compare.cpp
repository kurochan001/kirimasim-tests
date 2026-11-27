#include <array>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <type_traits>
#include "Vlayout___024root.h"

using overlay = decltype(Vlayout___024root::test_unpacked_union_c_member_order__DOT__specimen);
using left = decltype(overlay::__PVT__left);
using right = decltype(overlay::__PVT__right);

extern "C" void measure_c_layout(std::size_t *values);
extern "C" int observe_c_left(const void *payload, std::size_t bytes);
extern "C" int write_c_right(void *payload, std::size_t bytes);

template <std::size_t N>
void print_layout(const char *label, const std::array<std::size_t, N>& values)
{
    std::printf("%s", label);
    for (const auto value : values)
        std::printf(" %zu", value);
    std::puts("");
}

int main()
{
    static_assert(std::is_union_v<overlay> && std::is_trivially_copyable_v<overlay>
                  && std::is_standard_layout_v<overlay>);
    static_assert(std::is_standard_layout_v<left> && std::is_standard_layout_v<right>);
    const std::array<std::size_t, 15> generated = {
        sizeof(overlay), alignof(overlay), offsetof(overlay, __PVT__left), offsetof(overlay, __PVT__right),
        sizeof(left), alignof(left), offsetof(left, __PVT__marker), offsetof(left, __PVT__codepoint),
        offsetof(left, __PVT__ratio),
        sizeof(right), alignof(right), offsetof(right, __PVT__marker), offsetof(right, __PVT__codepoint),
        offsetof(right, __PVT__mode), offsetof(right, __PVT__score),
    };
    std::array<std::size_t, 15> c_layout{};
    measure_c_layout(c_layout.data());
    print_layout("c", c_layout);
    print_layout("generated", generated);
    const bool ordered = offsetof(left, __PVT__marker) < offsetof(left, __PVT__codepoint)
        && offsetof(left, __PVT__codepoint) < offsetof(left, __PVT__ratio)
        && offsetof(right, __PVT__marker) < offsetof(right, __PVT__codepoint)
        && offsetof(right, __PVT__codepoint) < offsetof(right, __PVT__mode)
        && offsetof(right, __PVT__mode) < offsetof(right, __PVT__score);
    std::printf("layout=%d ascending=%d\n", generated == c_layout, ordered);
    if (generated != c_layout || !ordered)
        return 3;

    overlay data = {};
    data.__PVT__left = {};
    data.__PVT__left.__PVT__marker = 23;
    data.__PVT__left.__PVT__codepoint = 4815162342ULL;
    data.__PVT__left.__PVT__ratio = 3.75;
    const int c_reads = observe_c_left(&data, sizeof data);

    data.__PVT__right = {};
    const int c_writes = write_c_right(&data, sizeof data);
    const int cpp_reads = c_writes && data.__PVT__left.__PVT__marker == 62
        && static_cast<std::int64_t>(data.__PVT__left.__PVT__codepoint) == -391827465LL
        && static_cast<std::int16_t>(data.__PVT__right.__PVT__mode) == -51
        && data.__PVT__right.__PVT__score == -0.75;
    std::printf("c_reads=%d cpp_reads=%d\n", c_reads, cpp_reads);
    return c_reads && cpp_reads ? 0 : 4;
}
