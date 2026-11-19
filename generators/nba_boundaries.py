# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wide NBA capture, overlapping writes and next-time region observations.

All destinations have static lifetime and fixed size. One initial process
gives enqueue order, then mutates sources and indices before any NBA update.
The reference captures converted values and coordinates in that source order.
"""
from common import Case
from bitvector_queries import assign_literal
from interaction_bits import resize, two_state
from packed_lanes import pattern

NAME = "nba_boundaries"
VERSION = 1
CHAPTER = 10
WIDTHS = (63, 64, 65, 127, 128, 129, 255, 256, 257, 511, 512, 513)
FORMS = ("whole", "slice", "overlap", "array")
STATES = ("bit", "logic")
TIMINGS = ("immediate", "delayed")
DESCRIPTIONS = {
    "whole": "Wide nonblocking assignments capture signed values and preserve ordered whole-word updates",
    "slice": "Wide nonblocking slice writes capture runtime indices and preserve neighboring bits",
    "overlap": "Overlapping wide nonblocking writes preserve captured coordinates and source order",
    "array": "Wide nonblocking array writes capture element indices and preserve untouched guards",
}


def at(bits, position, value):
    index = len(bits) - position - 1
    return bits[:index] + value + bits[index + 1:]


def invert(bits):
    assert set(bits) <= {"0", "1"}
    return "".join("0" if bit == "1" else "1" for bit in bits)


def put(bank, base, data):
    start = len(bank) - base - len(data)
    assert 0 <= start <= len(bank) - len(data)
    return bank[:start] + data + bank[start + len(data):]


def observe(lines, expected, label, expression, value):
    lines.append(f'    $display("{label}=%b", {expression});')
    expected.append(label + "=" + value)


def make_case(width, form, state, timing):
    name = f"test_gen_nba_boundary_{form}_{state}_{timing}_w{width}"
    wide = width + 5
    declarations = ["  logic signed [W-1:0] source, peer;",
                    f"  typedef {state} signed [W+4:0] wide_t;",
                    "  wide_t captured, peer_capture;", "  integer nonce, found;"]
    if form == "whole":
        declarations += ["  wide_t target;"]
        current = "00000" + pattern(width, 8)
    elif form == "array":
        declarations += ["  wide_t target[-1:1];", "  integer index;"]
        current = {i: "00000" + at(pattern(width, i + 9), 0, "1" if i == 1 else "0")
                   for i in (-1, 0, 1)}
    else:
        declarations += [f"  {state} [3*W-1:0] target;", "  integer base, other;",
                         f"  {state} [16:0] patch_capture, peer_patch_capture;"]
        current = pattern(3 * width, 8)
    lines = ["    nonce = 0;", '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);',
             '    $display("widths=%0d,%0d", $bits(source), $bits(captured));']
    expected = [f"width={width} form={form} state={state} timing={timing}",
                "nonce=1 found=1", f"widths={width},{wide}"]
    if form == "array":
        for i in (-1, 0, 1):
            assign_literal(lines, f"target[{i}]", current[i])
    else:
        assign_literal(lines, "target", current)

    def convert(bits, destination_width):
        value = resize(bits, destination_width, True)
        return two_state(value) if state == "bit" else value

    def target_observation(label, values):
        if form == "array":
            for i, suffix in [(-1, "m1"), (0, "guard"), (1, "p1")]:
                observe(lines, expected, label + "_" + suffix, f"target[{i}]", values[i])
        else:
            observe(lines, expected, label, "target", values)

    delay = " #1" if timing == "delayed" else ""
    for phase in range(2):
        source = at(at(pattern(width, phase + 2), width - 1, "1"), 0, "1")
        peer = at(at(pattern(width, phase + 6), width - 1, "0"), 0, "0")
        first, second = (phase + 1) * width - 8, (phase + 1) * width - 3
        if form in ("slice", "overlap"):
            old_window = current[len(current) - first - 17:len(current) - first]
            patch = invert(old_window)
            source = source[:-17] + patch
            peer = peer[:-12] + invert(patch[:12])
        if phase:
            source = at(at(at(source, width - 1, "x"), 31, "x"), 3, "z")
            peer = at(at(at(peer, width - 1, "z"), 32, "z"), 5, "x")
        assert source[-1] in "01" and peer[-1] in "01"
        assign_literal(lines, "source", source[:-1] + invert(source[-1]))
        assign_literal(lines, "peer", peer[:-1] + invert(peer[-1]))
        lines += ["    source[0] = source[0] ^ nonce[0];",
                  "    peer[0] = peer[0] ^ nonce[0];",
                  "    captured = source;", "    peer_capture = peer;"]
        captured, peer_capture = convert(source, wide), convert(peer, wide)
        observe(lines, expected, f"p{phase}_source", "source", source)
        observe(lines, expected, f"p{phase}_peer", "peer", peer)
        observe(lines, expected, f"p{phase}_capture", "captured", captured)
        observe(lines, expected, f"p{phase}_peer_capture", "peer_capture", peer_capture)
        if form == "whole":
            lines.append(f"    target <={delay} source;")
            if phase:
                lines.append(f"    target <={delay} peer;")
            after = peer_capture if phase else captured
        elif form == "array":
            first_index, second_index = (-1, 1) if phase == 0 else (1, 1)
            lines += [f"    index = {first_index};", f"    target[index] <={delay} source;",
                      f"    index = {second_index};", f"    target[index] <={delay} peer;",
                      "    index = 0;", f'    $display("p{phase}_mutated_index=%0d", index);']
            expected.append(f"p{phase}_mutated_index=0")
            after = dict(current)
            after[first_index], after[second_index] = captured, peer_capture
        else:
            patch, peer_patch = convert(source, 17), convert(peer, 17)
            lines += ["    patch_capture = source;", "    peer_patch_capture = peer;"]
            observe(lines, expected, f"p{phase}_patch", "patch_capture", patch)
            observe(lines, expected, f"p{phase}_peer_patch", "peer_patch_capture", peer_patch)
            lines += [f"    base = {first};", f"    other = {second};",
                      f"    target[base +: 17] <={delay} source;"]
            after = put(current, first, patch)
            if form == "overlap":
                lines.append(f"    target[other +: 17] <={delay} peer;")
                after = put(after, second, peer_patch)
            lines += ["    base = 3;", "    other = 8;",
                      f'    $display("p{phase}_mutated_indices=%0d,%0d", base, other);']
            expected.append(f"p{phase}_mutated_indices=3,8")
        lines += ["    source = '0;", "    peer = '1;"]
        observe(lines, expected, f"p{phase}_mutated_source", "source", "0" * width)
        observe(lines, expected, f"p{phase}_mutated_peer", "peer", "1" * width)
        target_observation(f"p{phase}_active", current)
        lines.append("    #1;")
        target_observation(f"p{phase}_tick1", current if timing == "delayed" else after)
        lines.append("    #1;")
        target_observation(f"p{phase}_tick2", after)
        current = after
    note = ("Every destination has module-static lifetime and fixed size. One sequential "
            "initial process establishes source order, captures RHS values and LHS indices, "
            "then changes both sources and runtime coordinates before updates. An Active "
            "observation remains before the current NBA region. At the next time's Active "
            "region, an immediate NBA is complete but an intra-assignment #1 NBA is still "
            "pending; both are complete one time later. There are no concurrent writers, "
            "automatic destinations, dynamic arrays or unspecified index side effects. "
            "Known and X/Z phases observe complete sources, converted blocking controls "
            "and all destination bits. The +nonce=1 dependency changes only known low bits.")
    if form in ("slice", "overlap"):
        note += (" Seventeen-bit windows cross the W and 2W boundaries of a 3W-bit bank. "
                 "The initial patch complements its old window. Overlapping writes, when "
                 "present, overlap twelve bits and must retain enqueue order while "
                 "preserving every unselected neighboring bit.")
    if form in ("whole", "array"):
        note += (" Signed W-bit sources extend to W+5-bit destinations before final state "
                 "conversion. The second phase includes two clearly ordered updates to "
                 "the same word, so the peer value wins without a race.")
    body = ([f"module {name};", "  timeunit 1ns;", "  timeprecision 1ps;",
             f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form],
                "10.4.2 4.6 4.4.2.2 4.4.2.4 9.4.5 11.5.1 7.4.1 7.4.2 6.11.2 20.6.2 3.14.2 21.6",
                note, "\n".join(body), "\n".join(expected) + "\n",
                fourstate=True, extra={"args": "+nonce=1"})


def cases():
    return [make_case(width, form, state, timing) for width in WIDTHS
            for form in FORMS for state in STATES for timing in TIMINGS]
