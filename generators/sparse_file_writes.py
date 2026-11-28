# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Seek beyond EOF without extending a file until a subsequent write."""

from itertools import product

from common import Case

NAME = "sparse_file_writes"
VERSION = 1
CHAPTER = 21

ORIGINS = {"start": 0, "current": 1, "end": 2}
PREFIXES = {"empty": b"", "seeded": bytes((0xC5, 0x00, 0xFE))}
SUFFIX = bytes((0xD2, 0x7A))


def make_case(origin, gap, profile):
    prefix = PREFIXES[profile]
    end = len(prefix)
    target = end + gap
    operation = ORIGINS[origin]
    # Anchor a current-relative seek inside the seeded file, not at its end.
    current = max(0, end - 1) if origin == "current" else 0
    offset = target - (0, current, end)[operation]
    name = f"test_gen_sparse_seek_{origin}_{gap}_{profile}"
    seed = ('    $fwrite(fd, "%c%c%c", 8\'hc5, 8\'h00, 8\'hfe);\n'
            if prefix else "")
    contents = prefix + bytes(gap) + SUFFIX
    expected = [f"seek=0 pos={target} end_before={end}",
                f"written_pos={target + len(SUFFIX)} end_after={len(contents)}",
                "data:" + "".join(f" {value:02x}" for value in contents),
                "end_read=-1"]

    body = f"""module {name};
  int fd, code, position, end_before, end_after, written_pos, next_byte;
  int offset, operation;

  initial begin
    fd = $fopen("sparse.bin", "w+b");
    if (fd == 0) $fatal(1, "update open failed");
{seed}    if ($fseek(fd, {current}, 0) != 0) $fatal(1, "anchor seek failed");
    offset = {offset};
    operation = {operation};
    code = $fseek(fd, offset, operation);
    position = $ftell(fd);
    if ($fseek(fd, 0, 2) != 0) $fatal(1, "first EOF seek failed");
    end_before = $ftell(fd);
    $display("seek=%0d pos=%0d end_before=%0d", code, position, end_before);
    if ($fseek(fd, position, 0) != 0) $fatal(1, "restore seek failed");
    $fwrite(fd, "%c%c", 8'hd2, 8'h7a);
    written_pos = $ftell(fd);
    if ($fseek(fd, 0, 2) != 0) $fatal(1, "second EOF seek failed");
    end_after = $ftell(fd);
    $display("written_pos=%0d end_after=%0d", written_pos, end_after);
    if ($rewind(fd) != 0) $fatal(1, "rewind failed");
    $write("data:");
    for (int i = 0; i < {len(contents)}; i++) begin
      next_byte = $fgetc(fd);
      if (next_byte < 0) $fatal(1, "unexpected EOF at byte %0d", i);
      $write(" %02h", next_byte[7:0]);
    end
    $display("");
    next_byte = $fgetc(fd);
    $display("end_read=%0d", next_byte);
    $fclose(fd);
  end
endmodule"""
    return Case(name, "Seeking beyond EOF preserves length until a write fills a zero gap",
                "21.3.5 21.3.4.1",
                "Seek beyond EOF from each origin, measure EOF without writing, then write "
                "at the saved position. Observe the file size and position, all original "
                "bytes, each byte of the zero-filled gap and the first new bytes.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(ORIGINS, (1, 2, 7, 16), PREFIXES)]
