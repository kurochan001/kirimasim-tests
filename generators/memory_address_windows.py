# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Explicit memory-file addresses with bounded ascending and descending loads.

Addresses are hexadecimal in either file format. A bad address is inside the
declared memory but outside the task's start/finish window. A later legal
record distinguishes termination from merely skipping the offending word.
"""

from itertools import product

from common import Case

NAME = "memory_address_windows"
VERSION = 1
CHAPTER = 21

DEFAULT_WORD = 0xEE
SCENARIOS = ("rebase", "below", "above")


def words_for_load(low, start, finish, records):
    """Interpret explicit record addresses and implicit following addresses."""
    memory = [DEFAULT_WORD] * 8
    address = start
    step = 1 if start < finish else -1
    for requested, data in records:
        if requested is not None:
            address = requested
        if not min(start, finish) <= address <= max(start, finish):
            break
        memory[address - low] = data
        address += step
    return memory


def format_data(value, radix, grouped):
    digits = f"{value:08b}" if radix == "binary" else f"{value:02x}"
    middle = len(digits) // 2
    return digits[:middle] + "_" + digits[middle:] if grouped else digits


def make_case(radix, declaration, direction, layout, scenario):
    low = 3 if radix == "binary" else 13
    high = low + 7
    left, right = (low, high) if declaration == "up" else (high, low)
    start, finish = (low + 1, high - 1) if direction == "up" else (high - 1, low + 1)
    step = 1 if start < finish else -1
    rebase = {"rebase": start + 3 * step, "below": low, "above": high}[scenario]
    records = ((start, 0xA5), (None, 0x3C), (rebase, 0x67), (None, 0xB2), (finish, 0x4D))
    expected = words_for_load(low, start, finish, records)
    tokens = []
    for address, data in records:
        if address is not None:
            tokens.append(f"@{address:x}")
        tokens.append(format_data(data, radix, layout == "comments"))

    name = f"test_gen_memory_window_{radix}_{declaration}_{direction}_{layout}_{scenario}"
    if layout == "inline":
        text = [" ".join(tokens)]
    else:
        # A valid-looking record in each comment would modify the guard cells.
        text = [f"/* @{low:x} 0 */", f"{tokens[0]} {tokens[1]} // @{high:x} 0",
                f"{tokens[2]} /* skipped @{low:x} 0 */ {tokens[3]}", " ".join(tokens[4:])]
    task = "$readmemb" if radix == "binary" else "$readmemh"
    extra = {} if scenario == "rebase" else {
        "expected_stderr_regex": (r"(?im)^(?=[^\n]*\berror\b)(?=[^\n]*window\.mem)"
                                  r"(?=[^\n]*address)(?=[^\n]*(?:out of range|outside))[^\n]+")
    }
    lines = [f"module {name};", f"  logic [7:0] memory [{left}:{right}];", "  integer fd;",
             "  initial begin", "    foreach (memory[i]) memory[i] = 8'hee;",
             '    fd = $fopen("window.mem", "w");',
             '    if (fd == 0) $fatal(1, "could not create the memory file");']
    lines += [f'    $fdisplay(fd, "{line}");' for line in text]
    lines += ["    $fclose(fd);", f'    {task}("window.mem", memory, {start}, {finish});',
              f"    for (int i = {low}; i <= {high}; i++)",
              '      $display("mem[%0d]=%02h", i, memory[i]);',
              "    $finish(0);", "  end", "endmodule"]
    return Case(name, "Memory load applies explicit addresses only within the requested window",
                "21.4",
                "Check every cell in numeric index order. Explicit addresses rebase the load "
                "while implicit words retain the direction chosen by the task arguments. "
                "An out-of-window address must stop the load even when the file later "
                "returns to the window. The comment layout also tests ignored address-like "
                "text and underscores within data words.",
                "\n".join(lines), "".join(f"mem[{low+i}]={word:02x}\n"
                                            for i, word in enumerate(expected)), extra=extra)


def cases():
    return [make_case(*row) for row in product(("binary", "hex"), ("up", "down"),
                                              ("up", "down"), ("inline", "comments"), SCENARIOS)]
