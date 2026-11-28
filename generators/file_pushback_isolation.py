# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Reposition one file descriptor while another handle retains its pushback."""

from itertools import product

from common import Case

NAME = "file_pushback_isolation"
VERSION = 1
CHAPTER = 21

OCTETS = (0xC5, 0x37, 0x00, 0xFF, 0xA9, 0x28, 0xB3, 0x61)
PROFILES = {"low": (0, 1, 4), "mid": (1, 3, 5),
            "high": (2, 5, 6), "back": (5, 6, 1)}
SEEK = {
    "absolute": "$fseek(first_fd, destination, 0)",
    "relative": "$fseek(first_fd, destination - pending, 1)",
    "end": f"$fseek(first_fd, destination - {len(OCTETS)}, 2)",
    "rewind": "$rewind(first_fd)",
}


def make_case(origin, profile, mode, read):
    start_a, start_b, destination = PROFILES[profile]
    if origin == "rewind":
        destination = 0
    name = f"test_gen_pushback_{origin}_{profile}_{mode}_{read}"
    expected = [f"first={OCTETS[start_a]:02x}/{OCTETS[start_b]:02x}",
                f"seek=0/{destination}"]
    if read == "byte":
        expected += [f"moved={OCTETS[destination]:02x} pos={destination + 1}"]
        moved = ["    first_char = $fgetc(first_fd);",
                 "    position = $ftell(first_fd);",
                 '    $display("moved=%02h pos=%0d", first_char[7:0], position);']
    else:
        hexword = "".join(f"{v:02x}" for v in OCTETS[destination:destination + 2])
        expected += [f"moved={hexword} count=2 pos={destination + 2}"]
        moved = ["    count = $fread(word_value, first_fd);",
                 "    position = $ftell(first_fd);",
                 '    $display("moved=%04h count=%0d pos=%0d", word_value, count, position);']
    expected += [f"other=9d/{OCTETS[start_b + 1]:02x} pos={start_b + 2}"]
    relative = "    pending = $ftell(first_fd);\n" if origin == "relative" else ""
    position_vars = "position, pending" if origin == "relative" else "position"
    destination_var = "  int destination;\n" if origin != "rewind" else ""
    destination_init = f"    destination = {destination};\n" if origin != "rewind" else ""
    read_vars = "  logic [15:0] word_value;\n  int count;\n" if read == "word" else ""
    read_lines = "\n".join(moved)
    first_mode = "r+b" if mode == "update" else "rb"
    octet_literals = [f"8'h{byte:02x}" for byte in OCTETS]
    writes = "\n".join(
        f'    $fwrite(writer, "%c%c%c%c", {", ".join(octet_literals[i:i + 4])});'
        for i in range(0, len(OCTETS), 4)
    )
    body = f"""module {name};
  int writer, first_fd, second_fd, first_char, second_char, code, {position_vars};
{destination_var}{read_vars}
  initial begin
    writer = $fopen("pushback.bin", "wb");
    if (writer == 0) $fatal(1, "write open failed");
{writes}
    $fclose(writer);
    first_fd = $fopen("pushback.bin", "{first_mode}");
    second_fd = $fopen("pushback.bin", "rb");
    if (first_fd == 0 || second_fd == 0) $fatal(1, "read open failed");
    if ($fseek(first_fd, {start_a}, 0) != 0) $fatal(1, "first anchor");
    if ($fseek(second_fd, {start_b}, 0) != 0) $fatal(1, "second anchor");
    first_char = $fgetc(first_fd);
    second_char = $fgetc(second_fd);
    $display("first=%02h/%02h", first_char[7:0], second_char[7:0]);
    if ($ungetc(8'h83, first_fd) < 0) $fatal(1, "first pushback");
    if ($ungetc(8'h9d, second_fd) < 0) $fatal(1, "second pushback");
{destination_init}{relative}    code = {SEEK[origin]};
    position = $ftell(first_fd);
    $display("seek=%0d/%0d", code, position);
{read_lines}
    first_char = $fgetc(second_fd);
    second_char = $fgetc(second_fd);
    position = $ftell(second_fd);
    $display("other=%02h/%02h pos=%0d", first_char[7:0], second_char[7:0], position);
    $fclose(first_fd);
    $fclose(second_fd);
  end
endmodule"""
    return Case(name, "File repositioning cancels pushback on only the moved descriptor",
                "21.3.5 21.3.4.1" + (" 21.3.4.4" if read == "word" else ""),
                "Open one file through two descriptors and push a different byte onto each. "
                "Seek or rewind one handle. Verify its next byte or word, then consume the "
                "other handle's pushed byte and its following original byte.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(SEEK, PROFILES, ("read", "update"), ("byte", "word"))]
