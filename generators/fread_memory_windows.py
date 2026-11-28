# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Binary memory reads with explicit and omitted address/count arguments."""

from itertools import product

from common import Case

NAME = "fread_memory_windows"
VERSION = 1
CHAPTER = 21

WIDTHS = (8, 9, 16, 24, 33, 65)
LOW, HIGH = 3, 7
WINDOWS = {
    "default": ("", LOW, 5),
    "count_only": (", , limit", LOW, 2),
    "start_only": (", start", LOW + 2, 3),
    "start_count": (", start, limit", LOW + 2, 2),
}


def make_case(width, descending, window):
    arguments, start, count = WINDOWS[window]
    bounds = f"{HIGH}:{LOW}" if descending else f"{LOW}:{HIGH}"
    order = "down" if descending else "up"
    name = f"test_gen_fread_memory_{width}_{order}_{window}"
    bytes_per_word = (width + 7) // 8
    mask = (1 << width) - 1
    guard = 0x19D78B54BC6A5ED32 & mask
    digit_count = (width + 3) // 4
    payload = bytes((0xB1 + 0x37 * offset) & 0xFF for offset in range(64))
    consumed = count * bytes_per_word
    words = [int.from_bytes(payload[offset:offset + bytes_per_word], "big") & mask
             for offset in range(0, consumed, bytes_per_word)]
    memory = [guard] * (HIGH - LOW + 1)
    memory[start - LOW:start - LOW + count] = words
    expected = [f"bytes={consumed} pos={consumed} next={payload[consumed]:02x}"]
    expected += [f"mem[{index}]={word:0{digit_count}x}"
                 for index, word in enumerate(memory, LOW)]

    body = f"""module {name};
  logic [{width - 1}:0] mem[{bounds}];
  int fd, start, limit, bytes_read, position, next_byte;

  initial begin
    fd = $fopen("payload.bin", "wb");
    if (fd == 0) $fatal(1, "write open failed");
    for (int i = 0; i < 64; i++) $fwrite(fd, "%c", byte'(8'hb1 + 8'h37*i));
    $fclose(fd);

    fd = $fopen("payload.bin", "rb");
    if (fd == 0) $fatal(1, "read open failed");
    for (int i = {LOW}; i <= {HIGH}; i++) mem[i] = {width}'h{guard:x};
    start = {start};
    limit = 2;
    bytes_read = $fread(mem, fd{arguments});
    position = $ftell(fd);
    next_byte = $fgetc(fd);
    $display("bytes=%0d pos=%0d next=%02h", bytes_read, position, next_byte[7:0]);
    for (int i = {LOW}; i <= {HIGH}; i++) $display("mem[%0d]=%h", i, mem[i]);
    $fclose(fd);
  end
endmodule"""
    observation = ""
    if (width, descending, window) == (65, True, "default"):
        observation = (" Verilator 5.054 retains excess high bits in mem[5]; "
                       "both formatting and equality expose the difference.")
    return Case(name, "Binary reads fill memory toward the highest address within the count",
                "21.3.4.4 21.3.5",
                "Use nonzero memory bounds and independently model big-endian words, "
                "including truncation at widths that are not a multiple of a byte. "
                "Observe every word, the byte count, and the next position and byte." + observation,
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(WIDTHS, (False, True), WINDOWS)]
