# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Associative locator keys with declared sign and more than one machine word."""

from itertools import product

from common import Case

NAME = "assoc_locator_widths"
VERSION = 1
CHAPTER = 7

WIDTHS = (31, 32, 33, 63, 64, 65, 129)
FILTERS = {"all": 0b111111, "mixed": 0b101101, "one": 0b000010, "none": 0}


def make_case(width, signed, profile):
    sign = 1 << (width - 1)
    keys = (sign + 3, 3, sign, 0, sign - 1, (sign << 1) - 1)
    order = sorted(range(len(keys)), key=lambda i: (keys[i] ^ sign) if signed else keys[i])
    wanted = FILTERS[profile]
    matches = [i for i in order if (wanted >> i) & 1]
    sign_name = "signed" if signed else "unsigned"
    name = f"test_gen_assoc_locator_{width}_{sign_name}_{profile}"
    size = (width + 3) // 4

    def endpoint(label, indexes):
        if not indexes:
            return f"{label}=0"
        index = indexes[0]
        return f"{label}=1 key={keys[index]:0{size}x} id={index}"

    expected = [
        f"bounds={keys[order[0]]:0{size}x}/{keys[order[-1]]:0{size}x}",
        endpoint("first", matches), endpoint("last", list(reversed(matches))),
        f"all={len(matches)} mask={wanted:02x} invalid=0",
    ]
    writes = "\n".join(f"    entry[{width}'h{key:x}] = {i};" for i, key in enumerate(keys))
    body = f"""module {name};
  typedef bit {'signed ' if signed else ''}[{width - 1}:0] key_t;
  int entry[key_t];
  key_t leftmost, rightmost;
  key_t first_hits[$], last_hits[$], hits[$];
  bit [5:0] wanted, seen;
  int invalid;

  initial begin
{writes}
    if (!entry.first(leftmost) || !entry.last(rightmost)) $fatal(1, "empty source");
    $display("bounds=%h/%h", leftmost, rightmost);
    wanted = 6'h{wanted:02x};
    first_hits = entry.find_first_index with (wanted[item]);
    last_hits = entry.find_last_index with (wanted[item]);
    hits = entry.find_index with (wanted[item]);
    $write("first=%0d", first_hits.size());
    if (first_hits.size() == 1)
      $write(" key=%h id=%0d", first_hits[0], entry[first_hits[0]]);
    $display("");
    $write("last=%0d", last_hits.size());
    if (last_hits.size() == 1)
      $write(" key=%h id=%0d", last_hits[0], entry[last_hits[0]]);
    $display("");
    seen = '0;
    invalid = 0;
    foreach (hits[i])
      if (entry.exists(hits[i])) seen[entry[hits[i]]] = 1'b1;
      else invalid++;
    $display("all=%0d mask=%02h invalid=%0d", hits.size(), seen, invalid);
  end
endmodule"""
    return Case(name, "Associative locators preserve declared key widths and ordering",
                "7.12.1 7.8.4 7.9.4 7.9.5",
                "Insert keys in a different order from the required traversal. Observe "
                "first and last separately from a locator, and check the unordered all-hit "
                "result by membership and count. Two wide keys have identical low words.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(WIDTHS, (False, True), FILTERS)]
