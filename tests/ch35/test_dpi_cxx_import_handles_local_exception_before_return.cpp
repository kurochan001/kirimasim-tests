#include <stdexcept>

extern "C" int checked_cell_index(int index)
{
    try {
        if (index < 0)
            throw std::out_of_range("negative cell index");
        return index * 3;
    } catch (const std::out_of_range &) {
        return -9;
    }
}
