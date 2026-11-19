# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Wide integral powers with complete, independently sized exponents.

Positive powers use modular integer exponentiation. Negative powers use the
integral cases of Table 11-4; explicit unknown operands retain four-state
results. Runtime input changes only known low bits, preserving supplied X/Z.
"""
from common import Case
from bitvector_queries import assign_literal
from interaction_bits import two_state

NAME = "power_boundaries"
VERSION = 1
CHAPTER = 11
WIDTHS = (63, 64, 65, 127, 128, 129, 255, 256, 257)
FORMS = ("positive", "negative", "wide_exp", "unknown")
DESCRIPTIONS = {
    "positive": "Runtime wide integral powers propagate result width before exponentiation",
    "negative": "Runtime integral powers distinguish negative exponents and zero-base unknown results",
    "wide_exp": "Wide power exponents retain high bits independently of base width and signing",
    "unknown": "Wide integral powers preserve unknown base and exponent observations",
}


def binary(value, width):
    return format(value & ((1 << width) - 1), f"0{width}b")


def at(bits, position, value):
    i = len(bits) - position - 1
    return bits[:i] + value + bits[i + 1:]


def low_toggle(bits):
    assert bits[-1] in "01"
    return bits[:-1] + ("1" if bits[-1] == "0" else "0")


def samples(width, form):
    mask, top = (1 << width) - 1, 1 << (width - 1)
    interior = (1 << (width - 2)) | (1 << (width // 2)) | 0x35
    if form == "positive":
        rows = [(0, 0), (0, 1), (1, 0), (mask, 3), (top, 2),
                (interior, 7), (3, 31), (mask - 1, 33)]
    elif form == "negative":
        rows = [(0, -1), (0, -2), (1, -1), (mask, -1), (mask, -2),
                (mask, -(1 << 32) - 1), (2, -3), (mask - 1, -2),
                (top, -(1 << 64))]
    elif form == "wide_exp":
        rows = [(3, 1 << 32), (3, (1 << 32) + 1), (mask, 1 << 63),
                (mask, (1 << 63) + 1), (interior, 1 << 64),
                (interior, (1 << 64) + 1), (5, (1 << 32) - 1)]
    else:
        assert form == "unknown"
        base = binary(interior, width)
        high = min(width - 1, 64)
        return [(at(base, high, "x"), binary(3, 65)),
                (at(base, 31, "z"), binary(2, 65)),
                (base, at(binary(3, 65), 64, "x")),
                (base, at(binary(2, 65), 32, "z")),
                (at(base, high, "z"), at(binary(3, 65), 32, "x")),
                (binary(3, width), binary(3, 65))]
    return [(binary(a, width), binary(e, 65)) for a, e in rows]


def power(base, exponent, source_signed, exponent_signed, result_width):
    if any(c in "xz" for c in base + exponent):
        return "x" * result_width
    a, e = int(base, 2), int(exponent, 2)
    if source_signed and base[0] == "1":
        a -= 1 << len(base)
    if exponent_signed and exponent[0] == "1":
        e -= 1 << len(exponent)
    if e < 0:
        if a == 0:
            return "x" * result_width
        value = 1 if a == 1 else ((-1 if e % 2 else 1) if a == -1 else 0)
    else:
        value = pow(a, e, 1 << result_width)
    return binary(value, result_width)


def make_case(width, signed, form):
    sign = "signed" if signed else "unsigned"
    fourstate = form in ("negative", "unknown")
    state = "logic" if fourstate else "bit"
    exp_signed = form == "negative"
    exp_sign = "signed" if exp_signed else "unsigned"
    name = f"test_gen_power_boundary_{form}_{sign}_w{width}"
    declarations = [f"  typedef {state} {sign} [W-1:0] word_t;",
                    f"  typedef {state} {exp_sign} [64:0] exponent_t;",
                    "  word_t base, narrow;", "  exponent_t exponent;",
                    "  logic [2*W-1:0] full, captured;", "  bit [2*W-1:0] converted;",
                    "  integer nonce, found;"]
    lines = ["    nonce = 0;", '    found = $value$plusargs("nonce=%d", nonce);',
             '    $display("nonce=%0d found=%0d", nonce, found != 0);']
    expected = [f"width={width} sign={sign} form={form} exponent={exp_sign}", "nonce=1 found=1"]
    for phase, (base, exponent) in enumerate(samples(width, form)):
        assign_literal(lines, "base", low_toggle(base))
        assign_literal(lines, "exponent", low_toggle(exponent))
        lines += ["    base[0] = base[0] ^ nonce[0];",
                  "    exponent[0] = exponent[0] ^ nonce[0];",
                  "    narrow = base ** exponent;", "    full = base ** exponent;",
                  "    captured = narrow;", "    converted = full;"]
        narrow = power(base, exponent, signed, exp_signed, width)
        full = power(base, exponent, signed, exp_signed, 2 * width)
        captured = (narrow[0] if signed else "0") * width + narrow
        for label, bits in [("base", base), ("exponent", exponent), ("narrow", narrow),
                            ("full", full), ("captured", captured), ("converted", two_state(full))]:
            lines.append(f'    $display("p{phase}_{label}=%b", {label});')
            expected.append(f"p{phase}_{label}={bits}")
        lines += [f'    $display("p{phase}_bits=%0d,%0d,%0d",',
                  "             $bits(base ** exponent), $bits(exponent), $bits(full));"]
        expected.append(f"p{phase}_bits={width},65,{2 * width}")
    note = ("The recorded +nonce=1 changes only the known low bit of each supplied operand. "
            "All other X/Z bits remain unchanged. The exponent is a separate 65-bit value; "
            "its size and signing neither affect the base's signing nor inherit the result "
            "context. A direct 2W-bit assignment extends the base before exponentiation, "
            "whereas a captured W-bit result extends afterward. Full base/exponent/result "
            "patterns, final two-state conversion and expression widths are observed. "
            "Positive powers use modular integer arithmetic; negative powers follow "
            "Table 11-4, including zero-base X and odd/even powers of signed minus one.")
    if form == "unknown":
        note += (" Unknown-operand samples use strictly positive known exponents or an "
                 "explicitly unknown exponent, avoiding an unknown base raised to zero. "
                 "The final all-known sample is a recovery control.")
    if form == "wide_exp":
        note += (" Exponents place known high bits at positions 32, 63 and 64, with odd "
                 "and even controls. No exponent is narrowed through a host-sized integer.")
    body = ([f"module {name};", f"  localparam int W = {width};"] + declarations +
            ["  initial begin", f'    $display("{expected[0]}");'] + lines +
            ["    $finish;", "  end", "endmodule"])
    return Case(name, DESCRIPTIONS[form],
                "11.4.3 11.6 11.6.1 11.8.1 11.8.2 6.11.2 20.6.2 21.6",
                note, "\n".join(body), "\n".join(expected) + "\n",
                fourstate=fourstate, extra={"args": "+nonce=1"})


def cases():
    return [make_case(width, signed, form) for width in WIDTHS
            for signed in (False, True) for form in FORMS]
