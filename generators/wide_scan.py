# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Independent wide numeric text, scan results and formatting controls.

Prepared input strings are separate from simulator formatting, so a matching
format/scan defect cannot cancel in a round trip. Radix digits expand to a
character bit stream before explicit destination truncation and conversion.
"""
from common import Case
from bitvector_queries import assign_literal
from interaction_bits import two_state

NAME = "wide_scan"
VERSION = 1
CHAPTER = 21
WIDTHS = (32, 33, 64, 65, 128, 129, 255, 256, 257)
FORMS = ("decimal", "binary", "hex", "octal", "bounded")
DESCRIPTIONS = {
    "decimal": "Wide decimal scanning and formatting retain complete signed and unsigned values",
    "binary": "Wide binary scanning preserves unknown digits before destination conversion",
    "hex": "Wide hexadecimal scanning and formatting preserve complete unknown digit groups",
    "octal": "Wide octal scanning and formatting preserve complete unknown digit groups",
    "bounded": "Scan field widths limit consumed characters independently of destination width",
}


def binary(value, width):
    return format(value & ((1 << width) - 1), f"0{width}b")


def pattern(width, salt):
    return int("".join("1" if (i * 11 + salt * 7) % 31 < 16 else "0"
                       for i in range(width)), 2)


def assign_text(lines, variable, text):
    assert all(c not in text for c in ('"', '\\', '\n'))
    chunks = [text[i:i + 64] for i in range(0, len(text), 64)]
    lines.append(f"    {variable} = {{")
    lines += ['      "' + chunk + '"' + (',' if i + 1 < len(chunks) else '')
              for i, chunk in enumerate(chunks)]
    lines.append("    };")


def parse_radix(text, group, width):
    bits = "".join(c.lower() * group if c.lower() in "xz" else
                   format(int(c, 16 if group == 4 else 8 if group == 3 else 2), f"0{group}b")
                   for c in text)
    return bits[-width:].rjust(width, "0")


def formatted(bits, code, signed):
    if code == "d":
        if "x" in bits:
            return "x" if set(bits) == {"x"} else "X"
        if "z" in bits:
            return "z" if set(bits) == {"z"} else "Z"
        value = int(bits, 2)
        if signed and bits[0] == "1":
            value -= 1 << len(bits)
        return str(value)
    group = {"b": 1, "h": 4, "o": 3}[code]
    padded = bits.rjust(((len(bits) + group - 1) // group) * group, "0")
    digits = []
    for i in range(0, len(padded), group):
        part = padded[i:i + group]
        if "x" in part:
            digits.append("x" if set(part) == {"x"} else "X")
        elif "z" in part:
            digits.append("z" if set(part) == {"z"} else "Z")
        else:
            digits.append(format(int(part, 2), "x" if group == 4 else "o" if group == 3 else "b"))
    return "".join(digits)


def inputs(width, form):
    if form == "decimal":
        top = 1 << (width - 1)
        values = ["1", "+" + str((top // 10) * 10 + 1),
                  "-" + str((pattern(width, 3) // 10) * 10 + 1),
                  str((((1 << (width + 5)) + pattern(width, 5)) // 10) * 10 + 1)]
        return [(text, binary(int(text), width), None) for text in values]
    if form == "bounded":
        result = []
        for phase in range(4):
            prefix = format(pattern(64, phase + 1), '016x')
            tail = format(((1 << (width + 5)) | pattern(width, phase + 5)) & ~15 | 1, 'x')
            text = prefix + ("a" if phase % 2 else "") + ":" + tail
            result.append((text, binary(int(prefix, 16), width),
                           binary(int(tail, 16), width) if phase % 2 == 0 else None))
        return result
    group = {"binary": 1, "hex": 4, "octal": 3}[form]
    radix = "b" if group == 1 else "x" if group == 4 else "o"
    full_groups = width // group
    result = []
    for phase in range(4):
        raw = (1 << (width + group + 2)) | pattern(width, phase + 1)
        digits = list(format(raw, radix))
        digits[-1] = "1"
        first = min(max(1, 32 // group), full_groups - 1)
        second = min(max(1, 64 // group), full_groups - 1)
        if second == first:
            second = 1 if first != 1 else 2
        if phase in (1, 3):
            digits[-1 - first] = "X" if phase == 1 else "x"
        if phase in (2, 3):
            digits[-1 - second] = "Z" if phase == 2 else "z"
        text = "".join(digits)
        result.append((text, parse_radix(text, group, width), None))
    return result


def make_case(width, signed, form, direct=False):
    sign = "signed" if signed else "unsigned"
    fourstate = form in ("binary", "hex", "octal")
    state = "logic" if fourstate else "bit"
    code = {"decimal": "d", "binary": "b", "hex": "h", "octal": "o", "bounded": "h"}[form]
    scan_format = "%16h:%h" if form == "bounded" else "%" + code
    format_string = "%0d" if code == "d" else "%" + code
    suffix = "_direct" if direct else ""
    name = f"test_gen_wide_scan_{form}_{sign}{suffix}_w{width}"
    declarations = [f"  typedef {state} {sign} [W-1:0] word_t;",
                    "  word_t scanned, tail_value, roundtrip, guard;",
                    "  bit [W-1:0] converted, binary_tail;",
                    "  string text, output_text;", "  integer digit, found;",
                    "  integer rc, rc_binary, rc_back, rc_bad;"]
    lines = ["    digit = 0;", '    found = $value$plusargs("digit=%d", digit);',
             '    $display("digit=%0d found=%0d", digit, found != 0);']
    expected = [f"width={width} sign={sign} form={form}", "digit=1 found=1"]
    if direct:
        expected[0] += " edit=direct"
    for phase, (text, bits, tail) in enumerate(inputs(width, form)):
        assert text[-1] == "1"
        guard = binary(pattern(width, phase + 9), width)
        assign_text(lines, "text", text[:-1] + "0")
        lines += ["    text[text.len()-1] = 48 + digit;" if direct else
                  "    text.putc(text.len()-1, 48 + digit);"]
        assign_literal(lines, "guard", guard)
        lines += ["    scanned = '0;", "    converted = '0;", "    tail_value = guard;",
                  "    binary_tail = guard;"]
        scan_args = "scanned, tail_value" if form == "bounded" else "scanned"
        binary_args = "converted, binary_tail" if form == "bounded" else "converted"
        lines += [f'    rc = $sscanf(text, "{scan_format}", {scan_args});',
                  f'    rc_binary = $sscanf(text, "{scan_format}", {binary_args});',
                  f'    output_text = $sformatf("{format_string}", scanned);',
                  "    roundtrip = '0;",
                  f'    rc_back = $sscanf(output_text, "%{code}", roundtrip);',
                  f'    rc_bad = $sscanf("$bad", "%{code}", guard);',
                  f'    $display("p{phase}_text=%s", text);',
                  f'    $display("p{phase}_value=%b", scanned);',
                  f'    $display("p{phase}_binary=%b", converted);',
                  f'    $display("p{phase}_format=%s", output_text);',
                  f'    $display("p{phase}_back=%b", roundtrip);',
                  f'    $display("p{phase}_guard=%b", guard);',
                  f'    $display("p{phase}_rc=%0d,%0d,%0d,%0d", rc, rc_binary, rc_back, rc_bad);']
        assigned = 2 if form == "bounded" and tail is not None else 1
        expected += [f"p{phase}_text={text}", f"p{phase}_value={bits}",
                     f"p{phase}_binary={two_state(bits)}", f"p{phase}_format={formatted(bits, code, signed)}",
                     f"p{phase}_back={bits}", f"p{phase}_guard={guard}",
                     f"p{phase}_rc={assigned},{assigned},1,0"]
        if form == "bounded":
            lines += [f'    $display("p{phase}_tail=%b", tail_value);',
                      f'    $display("p{phase}_binary_tail=%b", binary_tail);']
            expected += [f"p{phase}_tail={tail if tail is not None else guard}",
                         f"p{phase}_binary_tail={tail if tail is not None else guard}"]
    note = ("Prepared numeric input text is independent of simulator formatting. The recorded "
            "+digit=1 changes its last character from zero to one through putc, creating "
            "a runtime input dependency. Oversized fields retain their least significant W "
            "bits. Separate scans into the declared word type and bit storage observe "
            "conversion; exact formatted text and a round trip are additional controls. "
            "A conflicting first character must return zero assignments and preserve the "
            "initialized guard. Every input/result/return count is observed. Radix X/Z "
            "groups remain complete inside the destination so formatting cannot lose "
            "known bits through a partially unknown digit.")
    if form == "bounded":
        note += (" A maximum field width of sixteen hexadecimal characters is independent "
                 "of W. Even phases have the matching colon and two assignments; odd "
                 "phases have an extra hexadecimal character before it, stop after the "
                 "first assignment and retain the second destination's guard value.")
    if direct:
        note = note.replace("through putc", "through direct character assignment")
        note += (" This is the direct-index control for the corresponding putc program; "
                 "6.16.2 defines these character updates as semantically equivalent.")
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form],
                "21.3.4.3 21.3.3 21.2.1.1 21.2.1.2 21.2.1.3 6.11.2 5.9 11.10 6.16.1 6.16.2 21.6",
                note, "\n".join(body), "\n".join(expected) + "\n",
                fourstate=fourstate, extra={"args": "+digit=1"})


def cases():
    return [make_case(width, signed, form, direct) for direct in (False, True) for width in WIDTHS
            for signed in (False, True) for form in FORMS]
