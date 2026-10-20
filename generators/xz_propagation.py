"""Generates tests of how x and z bits in the operands of the operators of
IEEE 1800-2023 11.4 show in their results.

The reference model works on strings of the bits 0, 1, x and z, most
significant bit first, with one rule per clause: the truth tables of the
bitwise operators (11.4.8, z acts as x) applied bit by bit and, for the
reduction operators, folded over the bits (11.4.9); a whole result of x for
arithmetic with any unknown operand bit or a zero divisor (11.4.3); 1'bx for
a relational operator with an unknown bit (11.4.4); an x for == and != only
when no known bits differ (11.4.5); exact matches for === and !==, and x and z
of the right operand of ==? and !=? as wildcards (11.4.6); the truth value of
an operand being x when it has no 1 bit but an unknown one (11.4.7); an x
result for an unknown shift count (11.4.10); and Table 11-20 for ?: with an
unknown condition (11.4.11). Operands are unsigned unless a case says
otherwise, and zero-extended to a common width (11.4.8, 11.6.1).
"""

import random

from common import Case

NAME = "xz_propagation"
VERSION = 1
CHAPTER = 11
WIDTHS = [1, 4, 8, 13]


def known(s: str) -> bool:
    return all(c in "01" for c in s)


def band(a: str, b: str) -> str:
    if a == "0" or b == "0":
        return "0"
    return "1" if a == b == "1" else "x"


def bor(a: str, b: str) -> str:
    if a == "1" or b == "1":
        return "1"
    return "0" if a == b == "0" else "x"


def bxor(a: str, b: str) -> str:
    return str(int(a) ^ int(b)) if a in "01" and b in "01" else "x"


def bnot(a: str) -> str:
    return {"0": "1", "1": "0"}.get(a, "x")


def bitwise(f, a: str, b: str) -> str:
    return "".join(f(x, y) for x, y in zip(a, b))


def truth(v: str) -> str:
    if "1" in v:
        return "1"
    return "0" if set(v) == {"0"} else "x"


def fold(f, v: str) -> str:
    r = v[0]
    for c in v[1:]:
        r = f(r, c)
    return r


def arith(op: str, a: str, b: str) -> str:
    n = len(a)
    if not known(a) or not known(b) or (op in "/%" and int(b, 2) == 0):
        return "x" * n
    x, y = int(a, 2), int(b, 2)
    v = {"+": x + y, "-": x - y, "*": x * y, "/": x // (y or 1), "%": x % (y or 1)}[op]
    return format(v & ((1 << n) - 1), f"0{n}b")


def equality(a: str, b: str) -> str:
    if any(x in "01" and y in "01" and x != y for x, y in zip(a, b)):
        return "0"
    return "1" if known(a) and known(b) else "x"


def wildcard(a: str, b: str) -> str:
    unknown = False
    for x, y in zip(a, b):
        if y in "xz":
            continue
        if x in "xz":
            unknown = True
        elif x != y:
            return "0"
    return "x" if unknown else "1"


def relational(op: str, a: str, b: str) -> str:
    if not known(a) or not known(b):
        return "x"
    x, y = int(a, 2), int(b, 2)
    return str(int({"<": x < y, "<=": x <= y, ">": x > y, ">=": x >= y}[op]))


def shift(op: str, a: str, k: str, signed: bool) -> str:
    n = len(a)
    if not known(k):
        return "x" * n
    s = int(k, 2)
    if op in ("<<", "<<<"):
        return (a + "0" * s)[-n:] if s < n else "0" * n
    fill = a[0] if op == ">>>" and signed else "0"
    return (fill * s + a)[:n] if s < n else fill * n


def merge(a: str, b: str) -> str:
    """Table 11-20: the result of ?: for an unknown condition."""
    return "".join(x if x == y and x in "01" else "x" for x, y in zip(a, b))


def invert(r: str) -> str:
    return bnot(r)


# ---------------------------------------------------------------- values

def value(rng: random.Random, w: int, kind: str) -> str:
    """A w-bit value: "known" has only 0 and 1, "x" and "z" have at least
    one bit of that kind, "mixed" any bits."""
    weights = {"known": "01", "x": "01x", "z": "01z", "mixed": "01xz"}[kind]
    while True:
        v = "".join(rng.choice(weights) for _ in range(w))
        if kind == "known" or kind == "mixed" or kind in v:
            return v


def pairs(rng: random.Random, w: int, count: int = 6) -> list[tuple[str, str]]:
    kinds = [("known", "known"), ("x", "known"), ("known", "z"), ("mixed", "mixed"),
             ("z", "x"), ("mixed", "known"), ("known", "x"), ("x", "x")]
    return [(value(rng, w, ka), value(rng, w, kb)) for ka, kb in kinds[:count]]


def lit(v: str) -> str:
    return f"{len(v)}'b{v}"


def module(name: str, decls: list[str], steps: list[list[str]]) -> str:
    body = [f"module {name};"] + decls + ["", "  initial begin"]
    for i, step in enumerate(steps):
        if i:
            body.append("")
        body += step
    return "\n".join(body + ["  end", "endmodule"])


def vec(name: str, w: int, signed: bool = False) -> str:
    return f"  logic {'signed ' if signed else ''}[{w - 1}:0] {name};" if w > 1 else \
        f"  logic {'signed ' if signed else ''}{name};"


def case(name, desc, lrm, comment, decls, steps, out):
    return Case(name, desc, lrm, comment, module(name, decls, steps), "\n".join(out) + "\n",
                fourstate=True)


# ---------------------------------------------------------------- families

BITWISE = {"and": ("&", band), "or": ("|", bor), "xor": ("^", bxor),
           "xnor": ("~^", lambda a, b: bnot(bxor(a, b)))}


def bitwise_cases(rng):
    out = []
    for key, (op, f) in BITWISE.items():
        for i, w in enumerate(WIDTHS * 2):
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            steps, res = [], []
            for a, b in pairs(rng, w):
                steps.append([f"    a = {lit(a)};", f"    b = {lit(b)};", f"    r = a {op} b;",
                              '    $display("%b", r);'])
                res.append(bitwise(f, a, b))
            out.append(case(name, f"Bitwise {op} on {w}-bit operands with x and z bits follows "
                                  f"the truth table of the operator bit by bit",
                            "11.4.8", f"IEEE 1800-2023 §11.4.8: {op} is applied to each pair "
                            f"of bits with the operator's truth table, in which z acts like x; "
                            f"a known result in one bit position does not depend on the others. "
                            f"The operands have {w} bits.",
                            [vec("a", w), vec("b", w), vec("r", w)], steps, res))
    return out


def not_cases(rng):
    out = []
    for i, w in enumerate(WIDTHS):
        name = f"test_gen_xz_not_{i + 1:02d}"
        steps, res = [], []
        for a, _ in pairs(rng, w):
            steps.append([f"    a = {lit(a)};", "    r = ~a;", '    $display("%b", r);'])
            res.append("".join(bnot(c) for c in a))
        out.append(case(name, f"Bitwise negation of a {w}-bit operand turns 0 and 1 around and "
                              f"gives x for x and z bits",
                        "11.4.8", "IEEE 1800-2023 §11.4.8: ~ inverts each known bit, and its "
                        "result for an x or a z bit is x.",
                        [vec("a", w), vec("r", w)], steps, res))
    return out


REDUCTION = {"rand": ("&", band, False), "ror": ("|", bor, False), "rxor": ("^", bxor, False),
             "rnand": ("~&", band, True), "rnor": ("~|", bor, True), "rxnor": ("~^", bxor, True)}


def reduction_cases(rng):
    out = []
    for key, (op, f, neg) in REDUCTION.items():
        for i, w in enumerate(WIDTHS[1:] + [16]):
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            steps, res = [], []
            for a, _ in pairs(rng, w):
                steps.append([f"    a = {lit(a)};", f"    r = {op}a;", '    $display("%b", r);'])
                r = fold(f, a)
                res.append(bnot(r) if neg else r)
            fold_text = (f"{op} inverts the result of {op[1]}" if neg
                         else f"{op} is the plain fold")
            out.append(case(name, f"Reduction {op} of a {w}-bit operand with x and z bits folds "
                                  f"the operator's truth table over the bits",
                            "11.4.9 11.4.8", f"IEEE 1800-2023 §11.4.9: a reduction operator "
                            f"applies its binary truth table to the first two bits, then to "
                            f"that result and the next bit, and so on (z acts like x); "
                            f"{fold_text}. A single 0 decides & and a single 1 decides |, "
                            f"whatever the other bits are.",
                            [vec("a", w), "  logic r;"], steps, res))
    return out


def logical_cases(rng):
    out = []
    for key, op in (("lnot", "!"), ("land", "&&"), ("lor", "||")):
        for i, w in enumerate(WIDTHS):
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            steps, res = [], []
            for a, b in pairs(rng, w):
                if op == "!":
                    steps.append([f"    a = {lit(a)};", "    r = !a;", '    $display("%b", r);'])
                    res.append(bnot(truth(a)))
                else:
                    steps.append([f"    a = {lit(a)};", f"    b = {lit(b)};", f"    r = a {op} b;",
                                  '    $display("%b", r);'])
                    res.append((band if op == "&&" else bor)(truth(a), truth(b)))
            out.append(case(name, f"Logical {op} on {w}-bit operands is x only when the truth "
                                  f"of an operand that decides it is ambiguous",
                            "11.4.7", f"IEEE 1800-2023 §11.4.7: an operand is true when it has "
                            f"a 1 bit, false when all its bits are 0, and ambiguous otherwise; "
                            f"{op} then gives 1, 0 or, when the result is ambiguous, x. A false "
                            f"operand decides && and a true one decides ||.",
                            [vec("a", w), vec("b", w), "  logic r;"], steps, res))
    return out


ARITH = {"add": "+", "sub": "-", "mul": "*", "div": "/", "mod": "%"}


def arith_cases(rng):
    out = []
    for key, op in ARITH.items():
        for i, w in enumerate(WIDTHS):
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            ps = pairs(rng, w, 5)
            if op in "/%":
                ps.append((value(rng, w, "known"), "0" * w))
            steps, res = [], []
            for a, b in ps:
                steps.append([f"    a = {lit(a)};", f"    b = {lit(b)};", f"    r = a {op} b;",
                              '    $display("%b", r);'])
                res.append(arith(op, a, b))
            zero = (" A zero divisor also makes the whole result x." if op in "/%" else "")
            out.append(case(name, f"{op} on {w}-bit operands gives all x when any operand bit is "
                                  f"x or z",
                            "11.4.3", f"IEEE 1800-2023 §11.4.3: when any bit of an operand of "
                            f"an arithmetic operator is x or z, every bit of the result is x, "
                            f"even the bits that the unknown bit could not change.{zero}",
                            [vec("a", w), vec("b", w), vec("r", w)], steps, res))
    for i, w in enumerate(WIDTHS):
        name = f"test_gen_xz_neg_{i + 1:02d}"
        steps, res = [], []
        for a, _ in pairs(rng, w):
            steps.append([f"    a = {lit(a)};", "    r = -a;", '    $display("%b", r);'])
            res.append(arith("-", "0" * w, a))
        out.append(case(name, f"Unary minus of a {w}-bit operand with an x or z bit is all x",
                        "11.4.3", "IEEE 1800-2023 §11.4.3: unary minus is an arithmetic "
                        "operator, so an x or z bit in its operand makes the whole result x.",
                        [vec("a", w), vec("r", w)], steps, res))
    return out


RELATIONAL = {"lt": "<", "le": "<=", "gt": ">", "ge": ">="}


def relational_cases(rng):
    out = []
    for key, op in RELATIONAL.items():
        for i, w in enumerate(WIDTHS[1:]):
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            steps, res = [], []
            for a, b in pairs(rng, w):
                steps.append([f"    a = {lit(a)};", f"    b = {lit(b)};", f"    r = a {op} b;",
                              '    $display("%b", r);'])
                res.append(relational(op, a, b))
            out.append(case(name, f"{op} on {w}-bit operands is x when either operand has an x "
                                  f"or z bit",
                            "11.4.4", f"IEEE 1800-2023 §11.4.4: a relational operator yields "
                            f"1'bx when either operand contains x or z, even if the known bits "
                            f"alone would decide the comparison.",
                            [vec("a", w), vec("b", w), "  logic r;"], steps, res))
    return out


def equality_cases(rng):
    out = []
    table = {"eq": ("==", equality, "11.4.5"), "ne": ("!=", lambda a, b: invert(equality(a, b)),
                                                    "11.4.5"),
             "ceq": ("===", lambda a, b: str(int(a == b)), "11.4.5"),
             "cne": ("!==", lambda a, b: str(int(a != b)), "11.4.5"),
             "weq": ("==?", wildcard, "11.4.6"),
             "wne": ("!=?", lambda a, b: invert(wildcard(a, b)), "11.4.6")}
    texts = {
        "==": "== is 0 when a pair of known bits differs, x when no known bits differ but some "
              "bit is x or z, and 1 when the operands are known and equal",
        "!=": "!= is the inverse of ==, and x where == is x",
        "===": "=== compares x and z bits as values of their own, so its result is never x",
        "!==": "!== is the inverse of ===, and never x",
        "==?": "in ==? an x or z bit of the right operand matches any bit; an x or z bit of the "
               "left operand against a 0 or 1 makes the result x unless a known bit differs",
        "!=?": "!=? is the inverse of ==?, and x where ==? is x"}
    for key, (op, f, clause) in table.items():
        for i, w in enumerate(WIDTHS[1:]):
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            steps, res = [], []
            ps = pairs(rng, w, 5) + [(a := value(rng, w, "x"), a)]
            for a, b in ps:
                steps.append([f"    a = {lit(a)};", f"    b = {lit(b)};", f"    r = a {op} b;",
                              '    $display("%b", r);'])
                res.append(f(a, b))
            out.append(case(name, f"{op} on {w}-bit operands with x and z bits",
                            clause + (" 11.4.5" if clause == "11.4.6" else ""),
                            f"IEEE 1800-2023 §{clause}: {texts[op]}. The last pair compares a "
                            f"value with x bits to itself.",
                            [vec("a", w), vec("b", w), "  logic r;"], steps, res))
    return out


def shift_cases(rng):
    out = []
    for key, op in (("shl", "<<"), ("shr", ">>"), ("ashl", "<<<"), ("ashr", ">>>")):
        for i, w in enumerate([4, 8, 13, 8]):
            signed = op == ">>>" and i % 2 == 1
            name = f"test_gen_xz_{key}_{i + 1:02d}"
            steps, res = [], []
            amounts = ["011", "001", "0x1", "000", "1z0", "101"]
            vals = [value(rng, w, k) for k in ("x", "z", "known", "mixed", "x", "mixed")]
            if signed:
                vals[0] = "x" + vals[0][1:]
            for a, k in zip(vals, amounts):
                steps.append([f"    a = {lit(a)};", f"    k = {lit(k)};", f"    r = a {op} k;",
                              '    $display("%b", r);'])
                res.append(shift(op, a, k, signed))
            fill = ("the sign bit, here possibly x, is copied into the vacated positions"
                    if signed else "the vacated positions get 0")
            out.append(case(name, f"{op} of a {w}-bit {'signed' if signed else 'unsigned'} "
                                  f"operand moves x and z bits, and an unknown count makes the "
                                  f"result all x",
                            "11.4.10", f"IEEE 1800-2023 §11.4.10: a shift moves every bit of "
                            f"the left operand, x and z included, and {fill}. When the shift "
                            f"count has an x or z bit, the result is unknown in every bit.",
                            [vec("a", w, signed), "  logic [2:0] k;", vec("r", w, signed)],
                            steps, res))
    return out


def cond_cases(rng):
    out = []
    for i, w in enumerate(WIDTHS * 2):
        name = f"test_gen_xz_cond_{i + 1:02d}"
        both_z = i >= 6
        steps, res = [], []
        conds = ["1", "0", "x", "z", "x", "x"]
        if both_z:
            # Operands with z bits in the same positions, which Table 11-20
            # turns into x.
            ps = [(value(rng, w, "z"), value(rng, w, "known")) for _ in range(6)]
            ps = [(a, "".join("z" if x == "z" else y for x, y in zip(a, b))) for a, b in ps]
        else:
            # Operands without z bits, and the last pair equal.
            kinds = [("known", "x"), ("x", "known"), ("known", "known"), ("x", "x"),
                     ("known", "x"), ("x", "x")]
            ps = [(value(rng, w, ka), value(rng, w, kb)) for ka, kb in kinds]
            ps[5] = (ps[5][0], ps[5][0])
        for c, (a, b) in zip(conds, ps):
            steps.append([f"    c = 1'b{c};", f"    a = {lit(a)};", f"    b = {lit(b)};",
                          "    r = c ? a : b;", '    $display("%b", r);'])
            res.append(a if c == "1" else b if c == "0" else merge(a, b))
        detail = ("Here both operands have z bits in the same places, which the table turns "
                  "into x, not z, while a known condition passes them through." if both_z else
                  "The last case has equal operands with x bits, which stay x.")
        out.append(case(name, f"c ? a : b with an x or z condition on {w}-bit operands merges "
                              f"them bit by bit with Table 11-20"
                              + (", turning two z bits into x" if both_z else ""),
                        "11.4.11", "IEEE 1800-2023 §11.4.11: with a known condition ?: gives "
                        "one operand unchanged, x and z bits included. With an x or z "
                        "condition both are evaluated and combined bit by bit: equal 0 or 1 "
                        "bits stay, and every other pair, two z bits included, gives x. "
                        + detail,
                        ["  logic c;", vec("a", w), vec("b", w), vec("r", w)], steps, res))
    return out


def extension_cases(rng):
    out = []
    for i in range(8):
        wa, wb = [(4, 8), (8, 13), (1, 4), (13, 8)][i % 4]
        signed = i >= 4
        op = ["==", "&", "|", "^"][i % 4]
        name = f"test_gen_xz_extend_{i + 1:02d}"
        n = max(wa, wb)
        steps, res = [], []
        kinds = (("known", "x"), ("x", "known"), ("mixed", "mixed"), ("x", "z"),
                 ("known", "known"))
        for ka, kb in kinds:
            a, b = value(rng, wa, ka), value(rng, wb, kb)
            # A z sign bit is left out of the signed cases: they are about x.
            if signed:
                a, b = a.replace("z", "x"), b.replace("z", "x")
            ext = lambda v, w: (v[0] if signed else "0") * (n - w) + v
            ea, eb = ext(a, wa), ext(b, wb)
            steps.append([f"    a = {lit(a)};", f"    b = {lit(b)};", f"    r = a {op} b;",
                          '    $display("%b", r);'])
            if op == "==":
                res.append(equality(ea, eb))
            else:
                res.append(bitwise({"&": band, "|": bor, "^": bxor}[op], ea, eb))
        how = ("sign-extended, so an x sign bit is copied into the new bits" if signed
               else "zero-extended, so the new bits are 0 even when the top bit is x or z")
        kind = "signed" if signed else "unsigned"
        out.append(case(name, f"{op} on a {wa}-bit and a {wb}-bit {kind} operand extends the "
                              f"narrower one before x and z bits are combined",
                        "11.4.8 11.4.5 11.8.2", f"IEEE 1800-2023 §11.4.8, §11.8.2: operands of "
                        f"unequal width are extended to the wider one first; here they are "
                        f"{how}. Then {op} combines the bits with the usual rules for x and z.",
                        [vec("a", wa, signed), vec("b", wb, signed),
                         vec("r", 1 if op == "==" else n)], steps, res))
    return out


def cases() -> list[Case]:
    rng = random.Random(f"{NAME}@{VERSION}")
    return (bitwise_cases(rng) + not_cases(rng) + reduction_cases(rng) + logical_cases(rng)
            + arith_cases(rng) + relational_cases(rng) + equality_cases(rng) + shift_cases(rng)
            + cond_cases(rng) + extension_cases(rng))
