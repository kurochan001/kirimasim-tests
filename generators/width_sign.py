"""Generates tests of the bit length and the signedness of expressions
(IEEE 1800-2023 11.6 to 11.8), with operands and targets of 63 to 1000 bits.

The reference model evaluates each assignment with Python integers in the
steps of 11.8.2. The size of the expression comes from Table 11-21 together
with the target of the assignment, which is part of the context (11.6.1).
Its sign comes from 11.8.1: signed only when every context-determined operand
is signed, and part-selects and concatenations are unsigned. Each operand is
then extended to the size of the expression, with sign extension only when
the expression is signed, and the result is cut to the target.
"""

import random

from common import Case

NAME = "width_sign"
VERSION = 1
CHAPTER = 11
WIDTHS = [63, 64, 65, 127, 128, 129, 1000]


def mask(w: int) -> int:
    return (1 << w) - 1


def as_signed(v: int, w: int) -> int:
    return v - (1 << w) if v >> (w - 1) & 1 else v


def extend(v: int, w: int, signed: bool, n: int) -> int:
    """The w-bit pattern v extended to n >= w bits."""
    if signed and v >> (w - 1) & 1:
        return v | (mask(n) ^ mask(w))
    return v


def sign_word(s: bool) -> str:
    return "signed" if s else "unsigned"


def decl(name: str, w: int, s: bool) -> str:
    return f"  logic {'signed ' if s else ''}[{w - 1}:0] {name};"


def literal(v: int, w: int, indent: str) -> list[str]:
    """v as a w-bit value: one sized literal, or a concatenation of 64-bit
    pieces over several lines when it is too long for one."""
    if w <= 128:
        return [f"{w}'h{v:x}"]
    pieces, rest = [], w
    while rest > 0:
        size = rest % 64 or 64
        rest -= size
        pieces.append(f"{size}'h{(v >> rest) & mask(size):x}")
    lines, line = [], "{"
    for i, p in enumerate(pieces):
        part = p + (", " if i < len(pieces) - 1 else "}")
        if len(indent) + len(line) + len(part) > 96:
            lines.append(line.rstrip())
            line = "  "
        line += part
    lines.append(line)
    return lines


def assign(target: str, v: int, w: int) -> list[str]:
    indent = "    "
    parts = literal(v, w, indent)
    if len(parts) == 1:
        return [f"{indent}{target} = {parts[0]};"]
    out = [f"{indent}{target} ="]
    out += [indent + "  " + p for p in parts[:-1]]
    out.append(indent + "  " + parts[-1] + ";")
    return out


def values(rng: random.Random, w: int, nonzero: bool = False) -> list[int]:
    """Four w-bit values: patterns at the edges of the range and random ones."""
    patterns = [mask(w), 1 << (w - 1), mask(w - 1), 1, 5,
                rng.getrandbits(w) | 1 << (w - 1), rng.getrandbits(w), rng.getrandbits(w // 2)]
    picked = rng.sample(patterns, 4)
    return [p or 3 for p in picked] if nonzero else picked


def module(name: str, decls: list[str], steps: list[list[str]]) -> str:
    body = [f"module {name};"] + decls + ["", "  initial begin"]
    for i, step in enumerate(steps):
        if i:
            body.append("")
        body += step
    body += ["  end", "endmodule"]
    return "\n".join(body)


# ---------------------------------------------------------------- families

BINARY = {"add": "+", "sub": "-", "mul": "*", "and": "&", "or": "|", "xor": "^",
          "xnor": "~^", "div": "/", "mod": "%"}


def binary_value(op: str, x: int, y: int, n: int, s: bool) -> int:
    if s:
        x, y = as_signed(x, n), as_signed(y, n)
    if op == "+":
        v = x + y
    elif op == "-":
        v = x - y
    elif op == "*":
        v = x * y
    elif op == "&":
        v = x & y
    elif op == "|":
        v = x | y
    elif op == "^":
        v = x ^ y
    elif op == "~^":
        v = ~(x ^ y)
    else:
        q = abs(x) // abs(y) * (1 if (x < 0) == (y < 0) else -1)   # toward zero
        v = q if op == "/" else x - q * y
    return v & mask(n)


def why_sign(sa: bool, sb: bool) -> str:
    if sa and sb:
        return "both operands are signed"
    if sa or sb:
        return "one operand is unsigned"
    return "the operands are unsigned"


def binary_cases(rng: random.Random) -> list[Case]:
    cases = []
    for key, op in BINARY.items():
        for i in range(8):
            wa, wb, wr = rng.choice(WIDTHS), rng.choice(WIDTHS), rng.choice(WIDTHS)
            sa, sb = [(True, True), (True, False), (False, True), (False, False)][i % 4]
            n, s = max(wa, wb, wr), sa and sb
            name = f"test_gen_width_{key}_{i + 1:02d}"
            avs, bvs = values(rng, wa), values(rng, wb, nonzero=op in "/%")
            steps, out = [], []
            for a, b in zip(avs, bvs):
                r = binary_value(op, extend(a, wa, s, n), extend(b, wb, s, n), n, s) & mask(wr)
                steps.append(assign("a", a, wa) + assign("b", b, wb)
                             + [f"    r = a {op} b;", '    $display("%h", r);'])
                out.append(f"{r:0{(wr + 3) // 4}x}")
            ext = ("sign-extended" if s else "zero-extended, whatever their own sign")
            comment = (f"IEEE 1800-2023 §11.6.1, §11.8: a is a {wa}-bit {sign_word(sa)} and b a "
                       f"{wb}-bit {sign_word(sb)} variable, and r has {wr} bits. The expression "
                       f"a {op} b is {sign_word(s)} because {why_sign(sa, sb)} (11.8.1), and it "
                       f"is evaluated in {n} bits, the largest of a, b and r, with the operands "
                       f"{ext} (11.8.2); the result is then cut to the {wr} bits of r.")
            if op in "/%":
                comment += (" Signed division truncates toward zero, and the remainder has the "
                            "sign of the first operand (11.4.2).")
            cases.append(Case(name, f"{wa}-bit {sign_word(sa)} {op} {wb}-bit {sign_word(sb)} "
                                    f"assigned to {wr} bits is evaluated at the size and with the "
                                    f"sign that 11.6 and 11.8 give",
                              "11.6.1 11.8.1 11.8.2 11.4.2" if op in "/%" else
                              "11.6.1 11.8.1 11.8.2",
                              comment, module(name, [decl("a", wa, sa), decl("b", wb, sb),
                                                     decl("r", wr, False)], steps),
                              "\n".join(out) + "\n"))
    return cases


COMPARE = {"lt": "<", "le": "<=", "gt": ">", "ge": ">=", "eq": "==", "ne": "!="}


def compare_cases(rng: random.Random) -> list[Case]:
    cases = []
    for key, op in COMPARE.items():
        for i in range(3):
            wa, wb = rng.sample(WIDTHS, 2)
            sa, sb = [(True, True), (True, False), (False, True)][i]
            n, s = max(wa, wb), sa and sb
            name = f"test_gen_width_{key}_{i + 1:02d}"
            avs, bvs = values(rng, wa), values(rng, wb)
            steps, out = [], []
            for a, b in zip(avs, bvs):
                x, y = extend(a, wa, s, n), extend(b, wb, s, n)
                if s:
                    x, y = as_signed(x, n), as_signed(y, n)
                r = {"<": x < y, "<=": x <= y, ">": x > y, ">=": x >= y,
                     "==": x == y, "!=": x != y}[op]
                steps.append(assign("a", a, wa) + assign("b", b, wb)
                             + [f"    r = a {op} b;", '    $display("%b", r);'])
                out.append(str(int(r)))
            comment = (f"IEEE 1800-2023 §11.6.1, §11.8.1: the operands of a comparison are sized "
                       f"to each other, here to {n} bits, and compared as signed only when both "
                       f"are signed. a is {wa}-bit {sign_word(sa)} and b {wb}-bit "
                       f"{sign_word(sb)}, so they are compared as {sign_word(s)} numbers "
                       f"(11.4.4, 11.4.5), and the result is a single unsigned bit.")
            cases.append(Case(name, f"{wa}-bit {sign_word(sa)} {op} {wb}-bit {sign_word(sb)} "
                                    f"compares the operands extended to the larger width, as "
                                    f"{sign_word(s)} numbers",
                              "11.6.1 11.8.1 11.4.4 11.4.5", comment,
                              module(name, [decl("a", wa, sa), decl("b", wb, sb),
                                            "  logic r;"], steps),
                              "\n".join(out) + "\n"))
    return cases


SHIFT = {"shl": "<<", "shr": ">>", "ashl": "<<<", "ashr": ">>>"}


def shift_cases(rng: random.Random) -> list[Case]:
    cases = []
    for key, op in SHIFT.items():
        for i in range(4):
            wa, wr = rng.choice(WIDTHS), rng.choice(WIDTHS)
            sa = i % 2 == 0
            n = max(wa, wr)
            name = f"test_gen_width_{key}_{i + 1:02d}"
            avs = values(rng, wa)
            ks = [1, rng.randrange(2, wa), wa - 1, wa + 2]
            rng.shuffle(ks)
            steps, out = [], []
            for a, k in zip(avs, ks):
                x = extend(a, wa, sa, n)
                if op in ("<<", "<<<"):
                    v = x << k
                elif op == ">>" or not sa:
                    v = x >> k
                else:
                    v = as_signed(x, n) >> k
                r = v & mask(n) & mask(wr)
                steps.append(assign("a", a, wa) + [f"    k = {k};", f"    r = a {op} k;",
                                                   '    $display("%h", r);'])
                out.append(f"{r:0{(wr + 3) // 4}x}")
            kind = {"<<": "shifts in zeros", "<<<": "shifts in zeros like <<",
                    ">>": "shifts in zeros from the left",
                    ">>>": "fills with the sign bit when the expression is signed and with "
                           "zeros otherwise"}[op]
            comment = (f"IEEE 1800-2023 §11.4.10, §11.6.1: the result of a shift has the size of "
                       f"its left operand, which is context-determined, so the {wa}-bit "
                       f"{sign_word(sa)} a is first extended to the {n} bits of the assignment "
                       f"and then shifted; the shift count is self-determined and unsigned. "
                       f"{op} {kind}. r has {wr} bits.")
            cases.append(Case(name, f"{op} of a {wa}-bit {sign_word(sa)} operand assigned to "
                                    f"{wr} bits shifts the operand extended to the size of the "
                                    f"assignment",
                              "11.4.10 11.6.1 11.8.2", comment,
                              module(name, [decl("a", wa, sa), "  int unsigned k;",
                                            decl("r", wr, False)], steps),
                              "\n".join(out) + "\n"))
    return cases


def carry_cases(rng: random.Random) -> list[Case]:
    cases = []
    for i in range(8):
        wa = rng.choice(WIDTHS)
        wb = wa
        wr = rng.choice([w for w in WIDTHS if w != wa])
        sa = sb = i % 2 == 0
        n, s = max(wa, wb, wr), sa and sb
        name = f"test_gen_width_carry_{i + 1:02d}"
        avs, bvs = values(rng, wa), values(rng, wb)
        steps, out = [], []
        for a, b in zip(avs, bvs):
            x, y = extend(a, wa, s, n), extend(b, wb, s, n)
            total = binary_value("+", x, y, n, s)
            r = (total >> 1) & mask(wr)
            steps.append(assign("a", a, wa) + assign("b", b, wb)
                         + ["    r = (a + b) >> 1;", '    $display("%h", r);'])
            out.append(f"{r:0{(wr + 3) // 4}x}")
        keeps = ("so the carry out of the operands' width is kept and shifted into the result"
                 if wr > wa else "so the sum wraps at the width of the operands before the shift")
        comment = (f"IEEE 1800-2023 §11.6.1, §11.6.2: in r = (a + b) >> 1 the sum is "
                   f"context-determined, so it is computed in {n} bits, the larger of the "
                   f"{wa}-bit operands and the {wr}-bit r, {keeps}. The operands are "
                   f"{sign_word(sa)}; >> always shifts in zeros.")
        cases.append(Case(name, f"The sum in (a + b) >> 1 with {wa}-bit operands and a "
                                f"{wr}-bit target is computed at the size of the assignment",
                          "11.6.1 11.6.2 11.8.2", comment,
                          module(name, [decl("a", wa, sa), decl("b", wb, sb),
                                        decl("r", wr, False)], steps),
                          "\n".join(out) + "\n"))
    return cases


def unary_cases(rng: random.Random) -> list[Case]:
    cases = []
    for key, op in (("neg", "-"), ("not", "~")):
        for i in range(4):
            wa = rng.choice(WIDTHS)
            wr = rng.choice([w for w in WIDTHS if w != wa])
            sa = i % 2 == 0
            n = max(wa, wr)
            name = f"test_gen_width_{key}_{i + 1:02d}"
            steps, out = [], []
            for a in values(rng, wa):
                x = extend(a, wa, sa, n)
                r = ((-x) if op == "-" else ~x) & mask(n) & mask(wr)
                steps.append(assign("a", a, wa) + [f"    r = {op}a;", '    $display("%h", r);'])
                out.append(f"{r:0{(wr + 3) // 4}x}")
            comment = (f"IEEE 1800-2023 §11.6.1, §11.8.2: the operand of unary {op} is "
                       f"context-determined, so the {wa}-bit {sign_word(sa)} a is "
                       f"{'sign' if sa else 'zero'}-extended to the {n} bits of the assignment "
                       f"before {op} is applied, and the result is cut to the {wr} bits of r.")
            cases.append(Case(name, f"Unary {op} of a {wa}-bit {sign_word(sa)} operand "
                                    f"assigned to {wr} bits applies to the extended operand",
                              "11.6.1 11.8.2 11.4.3" if op == "-" else "11.6.1 11.8.2 11.4.8",
                              comment,
                              module(name, [decl("a", wa, sa), decl("r", wr, False)], steps),
                              "\n".join(out) + "\n"))
    return cases


def partsel_cases(rng: random.Random) -> list[Case]:
    cases = []
    for i in range(6):
        wa, wb = rng.choice(WIDTHS), rng.choice(WIDTHS)
        wr = rng.choice([w for w in WIDTHS if w > min(wa, wb)])
        n = max(wa, wb, wr)
        name = f"test_gen_width_partsel_{i + 1:02d}"
        steps, out = [], []
        for a, b in zip(values(rng, wa), values(rng, wb)):
            r1 = binary_value("+", extend(a, wa, True, n), extend(b, wb, True, n), n, True)
            r2 = binary_value("+", a, b, n, False)
            steps.append(assign("a", a, wa) + assign("b", b, wb)
                         + ["    r = a + b;", '    $display("%h", r);',
                            f"    r = a[{wa - 1}:0] + b;", '    $display("%h", r);'])
            out += [f"{r1 & mask(wr):0{(wr + 3) // 4}x}", f"{r2 & mask(wr):0{(wr + 3) // 4}x}"]
        comment = (f"IEEE 1800-2023 §11.8.1: a part-select is unsigned even when it selects the "
                   f"whole of a signed vector. a ({wa} bits) and b ({wb} bits) are signed, so "
                   f"a + b is signed and both are sign-extended to {n} bits; in a[{wa - 1}:0] "
                   f"+ b the part-select makes the expression unsigned, and both operands are "
                   f"zero-extended instead.")
        cases.append(Case(name, f"A part-select of the whole of a signed {wa}-bit operand is "
                                f"unsigned and makes the sum with a signed operand unsigned",
                          "11.8.1 11.8.2 11.6.1", comment,
                          module(name, [decl("a", wa, True), decl("b", wb, True),
                                        decl("r", wr, False)], steps),
                          "\n".join(out) + "\n"))
    return cases


def concat_cases(rng: random.Random) -> list[Case]:
    cases = []
    for i in range(6):
        wa, wb = rng.choice(WIDTHS[:6]), rng.choice(WIDTHS[:6])
        wr = rng.choice(WIDTHS)
        name = f"test_gen_width_concat_{i + 1:02d}"
        steps, out = [], []
        for a, b in zip(values(rng, wa), values(rng, wb)):
            r = ((a << wb) | b) & mask(wr)
            steps.append(assign("a", a, wa) + assign("b", b, wb)
                         + ["    r = {a, b};", '    $display("%h", r);'])
            out.append(f"{r:0{(wr + 3) // 4}x}")
        fit = (f"zero-extended to the {wr} bits of r even though a is signed" if wr > wa + wb
               else f"cut to its low {wr} bits" if wr < wa + wb else "assigned as it is")
        comment = (f"IEEE 1800-2023 §11.4.12, §11.8.1: a concatenation is unsigned and as wide "
                   f"as its operands together, which are self-determined. {{a, b}} with the "
                   f"signed {wa}-bit a and the signed {wb}-bit b has {wa + wb} bits and is "
                   f"{fit}.")
        cases.append(Case(name, f"A concatenation of signed {wa}-bit and {wb}-bit operands is "
                                f"unsigned, {wa + wb} bits wide, when assigned to {wr} bits",
                          "11.4.12 11.8.1 11.6.1", comment,
                          module(name, [decl("a", wa, True), decl("b", wb, True),
                                        decl("r", wr, False)], steps),
                          "\n".join(out) + "\n"))
    return cases


def cond_cases(rng: random.Random) -> list[Case]:
    cases = []
    for i in range(6):
        wa, wb, wr = rng.choice(WIDTHS), rng.choice(WIDTHS), rng.choice(WIDTHS)
        sa, sb = [(True, True), (True, False), (False, True)][i % 3]
        n, s = max(wa, wb, wr), sa and sb
        name = f"test_gen_width_cond_{i + 1:02d}"
        steps, out = [], []
        for j, (a, b) in enumerate(zip(values(rng, wa), values(rng, wb))):
            c = j % 2
            r = (extend(a, wa, s, n) if c else extend(b, wb, s, n)) & mask(wr)
            steps.append(assign("a", a, wa) + assign("b", b, wb)
                         + [f"    c = 1'b{c};", "    r = c ? a : b;", '    $display("%h", r);'])
            out.append(f"{r:0{(wr + 3) // 4}x}")
        comment = (f"IEEE 1800-2023 §11.4.11, §11.6.1, §11.8.1: the result of c ? a : b is as "
                   f"wide as the larger of a and b, and here of r too, since both are "
                   f"context-determined; it is signed only when both are. a is {wa}-bit "
                   f"{sign_word(sa)} and b {wb}-bit {sign_word(sb)}, so whichever is chosen is "
                   f"{'sign' if s else 'zero'}-extended to {n} bits.")
        cases.append(Case(name, f"c ? a : b with a {wa}-bit {sign_word(sa)} and a {wb}-bit "
                                f"{sign_word(sb)} operand extends the chosen one as the "
                                f"expression's sign says",
                          "11.4.11 11.6.1 11.8.1", comment,
                          module(name, [decl("a", wa, sa), decl("b", wb, sb), "  logic c;",
                                        decl("r", wr, False)], steps),
                          "\n".join(out) + "\n"))
    return cases


def power_cases(rng: random.Random) -> list[Case]:
    cases = []
    for i in range(4):
        wa, wr = rng.choice(WIDTHS), rng.choice(WIDTHS)
        n = max(wa, wr)
        name = f"test_gen_width_pow_{i + 1:02d}"
        steps, out = [], []
        for a, e in zip(values(rng, wa), [0, 1, 3, 7]):
            r = pow(a, e, 1 << n) & mask(wr)
            steps.append(assign("a", a, wa) + [f"    e = {e};", "    r = a ** e;",
                                               '    $display("%h", r);'])
            out.append(f"{r:0{(wr + 3) // 4}x}")
        comment = (f"IEEE 1800-2023 §11.4.3, §11.6.1: a ** e has the size of a, which is "
                   f"context-determined, so the unsigned {wa}-bit a is extended to the {n} bits "
                   f"of the assignment and the power is taken modulo 2**{n}; the exponent is "
                   f"self-determined. Any value to the power 0 is 1.")
        cases.append(Case(name, f"Power of an unsigned {wa}-bit operand assigned to {wr} bits "
                                f"is computed at the size of the assignment",
                          "11.4.3 11.6.1 11.8.2", comment,
                          module(name, [decl("a", wa, False), "  int unsigned e;",
                                        decl("r", wr, False)], steps),
                          "\n".join(out) + "\n"))
    return cases


def cases() -> list[Case]:
    rng = random.Random(f"{NAME}@{VERSION}")
    return (binary_cases(rng) + compare_cases(rng) + shift_cases(rng) + carry_cases(rng)
            + unary_cases(rng) + partsel_cases(rng) + concat_cases(rng) + cond_cases(rng)
            + power_cases(rng))
