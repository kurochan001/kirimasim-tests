"""Generates tests of values wider than 64 bits on the paths that a value
takes through a design: assignments between widths, selects of vectors and
of packed arrays, concatenation, replication, shifts and comparisons, and
the arguments and results of subroutines, for the widths 63, 64, 65, 127,
128, 129 and 200, 2-state and 4-state, signed and unsigned, with x and z in
the upper chunk (the bits above 64) of the 4-state values.

The reference model holds a value as its width and three masks: the bits
that are 1, x and z. It follows these rules:

- 6.11.2 and 10.7: assigning a value to a wider target extends it with its
  sign bit, x and z included, when it is signed, and with zeros otherwise; a
  narrower target keeps the low bits; a 2-state target turns x and z into 0.
- 7.4.1, 7.4.5 and 11.5.1: a part-select, an indexed part-select and a slice
  of a packed array give the bits they name; a write to one changes only them.
- 11.4.12 and 11.4.12.1: concatenation and replication put the bits side by
  side.
- 11.4.10: << and >> shift in zeros, >>> of a signed value shifts in copies of
  its sign bit; x and z bits move with the others, and a shift by the width or
  more leaves only the bits shifted in.
- 11.4.5: == is 0 when two known bits differ, x when otherwise some bit is x
  or z, and 1 otherwise; === compares x and z as values. 11.4.4: < is x when a
  bit is x or z, and compares the values otherwise, signed when both operands
  are signed. 11.4.11: with a condition of x, ?: gives the bits where both
  operands agree and x elsewhere (the operands of that case have no z).
- 20.6.2: $bits gives the width.
- 13.3, 13.4.1, 13.5.1 and 13.5.2: function results, task inputs and output
  and ref arguments carry the bits unchanged.
- 21.2.1.2 and 21.2.1.3: %h prints every digit, one for each group of four
  bits from the least significant, as x when all bits of the group are x, z
  when all are z, X when some are x and Z when some are z and none x; %b one
  character a bit; %0d the decimal value without padding, or one of x, z, X
  and Z by the same rule over the whole value.

The values are drawn from a fixed seed, so the generated files do not change
from one run to the next. x and z are placed in whole hexadecimal digits, so
that every value can be written as a hexadecimal literal.
"""

import random

from common import Case

NAME = "wide_paths"
VERSION = 1
CHAPTER = 11
WIDTHS = [63, 64, 65, 127, 128, 129, 200]


def mask(w: int) -> int:
    return (1 << w) - 1


class V:
    """A 4-state value of w bits."""

    def __init__(self, w: int, one: int = 0, x: int = 0, z: int = 0):
        self.w = w
        self.x = x & mask(w)
        self.z = z & mask(w) & ~self.x
        self.one = one & mask(w) & ~(self.x | self.z)

    @property
    def unknown(self) -> int:
        return self.x | self.z

    def bit(self, i: int) -> str:
        if self.x >> i & 1:
            return "x"
        if self.z >> i & 1:
            return "z"
        return "1" if self.one >> i & 1 else "0"

    def same(self, o: "V") -> bool:
        return (self.w, self.one, self.x, self.z) == (o.w, o.one, o.x, o.z)

    # --- display (21.2.1.2, 21.2.1.3)
    @staticmethod
    def group(chars: str) -> str:
        if all(c == "x" for c in chars):
            return "x"
        if all(c == "z" for c in chars):
            return "z"
        if "x" in chars:
            return "X"
        if "z" in chars:
            return "Z"
        return None

    def hex(self) -> str:
        digits = []
        for lo in range(0, self.w, 4):
            chars = [self.bit(i) for i in range(lo, min(lo + 4, self.w))]
            g = self.group(chars)
            digits.append(g if g else format(self.one >> lo & 15, "x"))
        return "".join(reversed(digits))

    def bin(self) -> str:
        return "".join(self.bit(i) for i in reversed(range(self.w)))

    def dec(self, signed: bool) -> str:
        if self.unknown:
            return self.group([self.bit(i) for i in range(self.w)])
        v = self.one
        if signed and v >> (self.w - 1) & 1:
            v -= 1 << self.w
        return str(v)

    # --- assignment (6.11.2, 10.7)
    def resize(self, n: int, signed: bool) -> "V":
        if n <= self.w:
            return V(n, self.one, self.x, self.z)
        fill = mask(n) ^ mask(self.w)
        top = self.bit(self.w - 1) if signed else "0"
        return V(n, self.one | (fill if top == "1" else 0), self.x | (fill if top == "x" else 0),
                 self.z | (fill if top == "z" else 0))

    def two_state(self) -> "V":
        return V(self.w, self.one)

    # --- selects (11.5.1, 7.4.5)
    def sel(self, lo: int, n: int) -> "V":
        return V(n, self.one >> lo, self.x >> lo, self.z >> lo)

    def put(self, lo: int, part: "V") -> "V":
        keep = mask(self.w) ^ (mask(part.w) << lo)
        return V(self.w, self.one & keep | part.one << lo, self.x & keep | part.x << lo,
                 self.z & keep | part.z << lo)

    # --- shifts (11.4.10)
    def shl(self, k: int) -> "V":
        return V(self.w, self.one << k, self.x << k, self.z << k)

    def shr(self, k: int, arithmetic: bool = False) -> "V":
        r = V(self.w, self.one >> k, self.x >> k, self.z >> k)
        if not arithmetic:
            return r
        n = min(k, self.w)
        fill = mask(self.w) ^ (mask(self.w - n) if n < self.w else 0)
        top = self.bit(self.w - 1)
        return V(self.w, r.one | (fill if top == "1" else 0), r.x | (fill if top == "x" else 0),
                 r.z | (fill if top == "z" else 0))

    # --- comparisons (11.4.4, 11.4.5)
    def eq(self, o: "V") -> "V":
        known = mask(self.w) & ~(self.unknown | o.unknown)
        if (self.one ^ o.one) & known:
            return V(1)
        return V(1, x=1) if self.unknown | o.unknown else V(1, 1)

    def case_eq(self, o: "V") -> "V":
        return V(1, int(self.same(o)))

    def lt(self, o: "V", signed: bool) -> "V":
        if self.unknown or o.unknown:
            return V(1, x=1)
        a, b = self.one, o.one
        if signed:
            a -= (a >> (self.w - 1) & 1) << self.w
            b -= (b >> (o.w - 1) & 1) << o.w
        return V(1, int(a < b))

    def cond_x(self, o: "V") -> "V":
        """x ? self : o, for operands without z (11.4.11, Table 11-20)."""
        assert not (self.z or o.z)
        differ = (self.one ^ o.one) | self.x | o.x
        return V(self.w, self.one & ~differ, differ)


def concat(*vs: V) -> V:
    w, one, x, z = 0, 0, 0, 0
    for v in vs:
        one, x, z, w = one << v.w | v.one, x << v.w | v.x, z << v.w | v.z, w + v.w
    return V(w, one, x, z)


# ---------------------------------------------------------------- values

def digits_literal(v: V) -> str:
    """The digits of v in hexadecimal; x and z have to fill whole digits."""
    out = []
    for lo in range(0, v.w, 4):
        chars = [v.bit(i) for i in range(lo, min(lo + 4, v.w))]
        g = V.group(chars)
        assert g in (None, "x", "z"), "x or z that does not fill a digit"
        out.append(g if g else format(v.one >> lo & 15, "x"))
    return "".join(reversed(out))


def literal_lines(v: V) -> list[str]:
    """v as one sized literal, or as a concatenation of 64-bit pieces over
    several lines when it is wider than 128 bits."""
    if v.w <= 128:
        return [f"{v.w}'h{digits_literal(v)}"]
    pieces, rest = [], v.w
    while rest > 0:
        size = rest % 64 or 64
        rest -= size
        pieces.append(f"{size}'h{digits_literal(v.sel(rest, size))}")
    lines, line = [], "{"
    for i, p in enumerate(pieces):
        part = p + (", " if i < len(pieces) - 1 else "}")
        if len(line) + len(part) > 80:
            lines.append(line.rstrip())
            line = " "
        line += part
    lines.append(line)
    return lines


def assign(target: str, v: V, indent: str = "    ") -> list[str]:
    parts = literal_lines(v)
    if len(parts) == 1:
        return [f"{indent}{target} = {parts[0]};"]
    return [f"{indent}{target} ="] + [indent + "  " + p for p in parts[:-1]] + \
           [indent + "  " + parts[-1] + ";"]


def two_state_values(rng: random.Random, w: int) -> list[V]:
    patterns = [mask(w), 1 << (w - 1), mask(w - 1), 5, rng.getrandbits(w) | 1 << (w - 1),
                rng.getrandbits(w), rng.getrandbits(w) & ~(1 << (w - 1))]
    return [V(w, p) for p in patterns]


def four_state_value(rng: random.Random, w: int, sign_x: bool = False) -> V:
    """A value with known low bits and x and z digits in the upper chunk (above
    bit 64, or in the top digits when the value has no more than 64 bits)."""
    base = rng.getrandbits(w)
    top_digit = (w - 1) // 4
    if w > 68:
        candidates = range(16, top_digit)
    else:
        candidates = range(top_digit - 3, top_digit)
    first, second = rng.sample(candidates, 2)
    x, z = 15 << 4 * first, 15 << 4 * second
    if sign_x or 64 < w <= 68:
        # the top digit, which holds the sign bit (for 65 bits, all of the upper chunk)
        x |= mask(w) ^ mask(4 * top_digit)
    return V(w, base, x, z)


def x_only_value(rng: random.Random, w: int) -> V:
    v = four_state_value(rng, w)
    return V(w, v.one, v.x | v.z)


# ---------------------------------------------------------------- families

def module(name: str, decls: list[str], steps: list[str]) -> str:
    return "\n".join([f"module {name};"] + decls + ["", "  initial begin"] + steps
                     + ["  end", "endmodule"])


def values_case(w: int) -> Case:
    """Chapter 6: assignments between widths and from 4-state to 2-state."""
    rng = random.Random(f"values-{w}")
    name = f"test_gen_wide_values_w{w}"
    a = four_state_value(rng, w)
    s = V(w, rng.getrandbits(w) | 1 << (w - 1))
    u = V(w, rng.getrandbits(w) | 1 << (w - 1))
    sx = four_state_value(rng, w, sign_x=True)
    neg = V(w, rng.getrandbits(w) | 1 << (w - 1))
    decls = [f"  logic [{w - 1}:0] a, u;", f"  bit [{w - 1}:0] b;",
             f"  logic signed [{w - 1}:0] s, sx;", f"  logic signed [{w + 7}:0] wide_s;",
             f"  logic [{w + 7}:0] wide_u;", f"  logic [{w - 9}:0] narrow;",
             f"  bit signed [{w - 1}:0] neg;"]
    steps, out = [], []
    steps += assign("a", a) + ["    b = a;", '    $display("a=%h", a);', '    $display("b=%h", b);']
    out += [f"a={a.hex()}", f"b={a.two_state().hex()}"]
    steps += assign("s", s) + ["    wide_s = s;", '    $display("signed extended=%h", wide_s);']
    out.append(f"signed extended={s.resize(w + 8, True).hex()}")
    steps += assign("u", u) + ["    wide_u = u;", '    $display("unsigned extended=%h", wide_u);']
    out.append(f"unsigned extended={u.resize(w + 8, False).hex()}")
    steps += assign("sx", sx) + ["    wide_s = sx;", '    $display("x sign extended=%h", wide_s);']
    out.append(f"x sign extended={sx.resize(w + 8, True).hex()}")
    steps += ["    narrow = a;", '    $display("truncated=%h", narrow);']
    out.append(f"truncated={a.resize(w - 8, False).hex()}")
    steps += assign("neg", neg) + ['    $display("decimal=%0d", neg);']
    out.append(f"decimal={neg.dec(True)}")
    comment = (f"IEEE 1800-2023 §6.11.2 and §10.7 with {w}-bit values: a 4-state value with x "
               "and z in its upper chunk loses them in a 2-state variable; a signed value "
               "assigned to a wider target is extended with its sign bit, also when that bit "
               "is x, and an unsigned one with zeros; a narrower target keeps the low bits. "
               "%h prints every digit (§21.2.1.2), with x, z, X and Z for unknown bits "
               "(§21.2.1.3), and %0d a negative 2-state value without padding.")
    return Case(name, f"Assignments of {w}-bit values to wider, narrower and 2-state targets",
                "6.11.2 10.7 21.2.1.3", comment, module(name, decls, steps),
                "\n".join(out) + "\n", fourstate=True, chapter=6)


def select_case(w: int, four: bool) -> Case:
    """Chapter 7: selects of a vector and of a packed array, and writes to them."""
    rng = random.Random(f"select-{w}-{four}")
    kind = "4state" if four else "2state"
    words = "4-state" if four else "2-state"
    name = f"test_gen_wide_select_w{w}_{kind}"
    t = "logic" if four else "bit"
    v = four_state_value(rng, w) if four else two_state_values(rng, w)[4]
    rows = [four_state_value(rng, w) if four else V(w, rng.getrandbits(w)) for _ in range(4)]
    part = V(12, rng.getrandbits(12))
    decls = [f"  {t} [{w - 1}:0] v;", f"  {t} [3:0][{w - 1}:0] m;", "  int i;"]
    steps, out = [], []
    steps += assign("v", v)
    hi, lo = w - 3, w - 40
    steps += [f'    $display("v[{hi}:{lo}]=%h", v[{hi}:{lo}]);']
    out.append(f"v[{hi}:{lo}]={v.sel(lo, hi - lo + 1).hex()}")
    for base in sorted({w // 2 - 8, w - 16} | ({56, 60} if w >= 76 else set())):
        steps += [f'    $display("v[{base} +: 16]=%h", v[{base} +: 16]);']
        out.append(f"v[{base} +: 16]={v.sel(base, 16).hex()}")
    steps += [f'    $display("v[{w - 1} -: 20]=%h", v[{w - 1} -: 20]);']
    out.append(f"v[{w - 1} -: 20]={v.sel(w - 20, 20).hex()}")
    for i in sorted({0, w - 8} | ({59, 63} if w >= 71 else set())):
        steps += [f"    i = {i};", '    $display("v[%0d +: 8]=%h", i, v[i +: 8]);']
        out.append(f"v[{i} +: 8]={v.sel(i, 8).hex()}")
    wlo = 58 if w > 70 else w - 12
    steps += [f"    v[{wlo} +: 12] = 12'h{part.one:03x};", '    $display("after the write v=%h", v);']
    v = v.put(wlo, part)
    out.append(f"after the write v={v.hex()}")
    for r, val in enumerate(rows):
        steps += assign(f"m[{r}]", val)
    whole = concat(*reversed(rows))
    steps += ['    $display("m=%h", m);', f'    $display("m[2][{w - 1} -: 8]=%h", m[2][{w - 1} -: 8]);',
              '    $display("m[2:1]=%h", m[2:1]);']
    out += [f"m={whole.hex()}", f"m[2][{w - 1} -: 8]={rows[2].sel(w - 8, 8).hex()}",
            f"m[2:1]={concat(rows[2], rows[1]).hex()}"]
    # Icarus Verilog 13.0 cannot compile a write through a variable index of a
    # packed array, so only the 2-state variant, which Verilator runs, has one.
    steps += ["    i = 3;", "    m[i][7:0] = 8'h5a;"] if not four else ["    m[3][7:0] = 8'h5a;"]
    steps += ['    $display("m[3]=%h", m[3]);']
    rows[3] = rows[3].put(0, V(8, 0x5A))
    out.append(f"m[3]={rows[3].hex()}")
    comment = (f"IEEE 1800-2023 §11.5.1 and §7.4.5 with {w}-bit {'4' if four else '2'}-state "
               "values: constant and indexed part-selects, also across bit 64 and with a "
               "variable base, give the bits they name, and a write to a part-select changes "
               "only those bits. §7.4.1: the packed array m of four rows is one vector, row 3 "
               "at the top; an element, a part-select of an element and a slice give their "
               "bits, and a write to a part-select of an element" + (" through a variable "
               "index" if not four else "") + " changes only those bits. %h prints "
               "every digit (§21.2.1.2" + (", §21.2.1.3" if four else "") + ").")
    return Case(name, f"Part-selects and packed array selects of {w}-bit {words} values",
                "7.4.1 7.4.5 11.5.1", comment, module(name, decls, steps),
                "\n".join(out) + "\n", fourstate=four, chapter=7)


def ops_case(w: int, four: bool) -> Case:
    """Chapter 11: concatenation, replication, shifts and comparisons."""
    rng = random.Random(f"ops-{w}-{four}")
    kind = "4state" if four else "2state"
    words = "4-state" if four else "2-state"
    name = f"test_gen_wide_ops_w{w}_{kind}"
    t = "logic" if four else "bit"
    if four:
        a, b = four_state_value(rng, w), four_state_value(rng, w)
        s = four_state_value(rng, w, sign_x=True)
        same_known = V(w, a.one ^ (rng.getrandbits(w) & a.unknown), a.x, a.z)
    else:
        vals = two_state_values(rng, w)
        a, b, s = vals[4], vals[5], vals[0]
    tt = V(w, rng.getrandbits(w))
    decls = [f"  {t} [{w - 1}:0] a, b, r;", f"  {t} signed [{w - 1}:0] s, t;",
             f"  {t} [{2 * w - 1}:0] two;", f"  {t} [{w + 7}:0] joined;", "  int k;"]
    steps, out = [], []
    steps += assign("a", a) + assign("b", b) + assign("s", s) + assign("t", tt)
    steps += ['    joined = {a, b[7:0]};', '    $display("{a, b[7:0]}=%h", joined);']
    out.append(f"{{a, b[7:0]}}={concat(a, b.sel(0, 8)).hex()}")
    steps += ['    two = {2{a}};', '    $display("{2{a}}=%h", two);',
              '    $display("{3{b[15:0]}}=%h", {3{b[15:0]}});']
    out += [f"{{2{{a}}}}={concat(a, a).hex()}",
            f"{{3{{b[15:0]}}}}={concat(*[b.sel(0, 16)] * 3).hex()}"]
    for k in sorted({1, 63, 64, 65, w - 1, w, w + 5}):
        steps += [f"    k = {k};", "    r = a << k;", '    $display("a << %0d=%h", k, r);',
                  "    r = a >> k;", '    $display("a >> %0d=%h", k, r);',
                  "    r = s >>> k;", '    $display("s >>> %0d=%h", k, r);']
        out += [f"a << {k}={a.shl(k).hex()}", f"a >> {k}={a.shr(k).hex()}",
                f"s >>> {k}={s.shr(k, True).hex()}"]
    steps += ['    $display("a << 70=%h", a << 70);']
    out.append(f"a << 70={a.shl(70).hex()}")
    pairs = [("a", "b", a, b), ("a", "a", a, a)]
    if four:
        steps += assign("r", same_known)
        pairs.append(("a", "r", a, same_known))
    for ln, rn, lv, rv in pairs:
        steps += [f'    $display("{ln} == {rn}: %b, {ln} != {rn}: %b, {ln} === {rn}: %b, '
                  f'{ln} < {rn}: %b", {ln} == {rn}, {ln} != {rn}, {ln} === {rn}, {ln} < {rn});']
        e = lv.eq(rv)
        ne = V(1, x=1) if e.x else V(1, 1 - e.one)
        out.append(f"{ln} == {rn}: {e.bin()}, {ln} != {rn}: {ne.bin()}, "
                   f"{ln} === {rn}: {lv.case_eq(rv).bin()}, {ln} < {rn}: {lv.lt(rv, False).bin()}")
    steps += ['    $display("s < t: %b, t < s: %b", s < t, t < s);']
    out.append(f"s < t: {s.lt(tt, True).bin()}, t < s: {tt.lt(s, True).bin()}")
    if four:
        c1, c2 = x_only_value(rng, w), x_only_value(rng, w)
        steps += assign("a", c1) + assign("b", c2) + \
            ["    r = 1'bx ? a : b;", '    $display("x ? a : b=%h", r);']
        out.append(f"x ? a : b={c1.cond_x(c2).hex()}")
    steps += ['    $display("$bits(a)=%0d $bits({a, b})=%0d", $bits(a), $bits({a, b}));']
    out.append(f"$bits(a)={w} $bits({{a, b}})={2 * w}")
    comment = (f"IEEE 1800-2023 §11.4 with {w}-bit {'4' if four else '2'}-state operands: "
               "concatenation and replication (§11.4.12, §11.4.12.1) put the bits side by "
               "side; << and >> shift in zeros and >>> of a signed value copies of its sign bit "
               "(§11.4.10), by amounts up to past the width, where only those bits remain; "
               "== is 0 when known bits differ and x when unknown bits leave it open, === "
               "compares x and z too (§11.4.5), and < is x with unknown bits (§11.4.4)"
               + ("; with an x condition ?: keeps the bits where both operands agree "
                  "(§11.4.11)" if four else "")
               + ". $bits gives the widths (§20.6.2).")
    return Case(name, f"Concatenation, replication, shifts and comparisons of {w}-bit {words} "
                "values", "11.4.10 11.4.12 11.4.12.1 11.4.5 11.4.4 20.6.2"
                + (" 11.4.11" if four else ""), comment, module(name, decls, steps),
                "\n".join(out) + "\n", fourstate=four, chapter=11)


def subroutine_case(w: int, four: bool) -> Case:
    """Chapter 13: function results, task inputs, output arguments, and in the
    2-state variant a ref argument, which Icarus Verilog 13.0 does not support."""
    rng = random.Random(f"subroutine-{w}-{four}")
    kind, words = ("4state", "4-state") if four else ("2state", "2-state")
    name = f"test_gen_wide_subroutine_w{w}_{kind}"
    t = "logic" if four else "bit"
    if four:
        a, b = four_state_value(rng, w), four_state_value(rng, w)
    else:
        a, b = V(w, rng.getrandbits(w) | 1 << (w - 1)), V(w, rng.getrandbits(w))
    sv = V(w, rng.getrandbits(w) | 1 << (w - 1))
    decls = [f"  {t} [{w - 1}:0] a, b, r;", f"  {t} signed [{w - 1}:0] s;",
             f"  {t} signed [{w + 15}:0] wide;", "",
             f"  function automatic {t} [{w - 1}:0] pick(bit second, {t} [{w - 1}:0] p, "
             f"{t} [{w - 1}:0] q);",
             "    return second ? q : p;", "  endfunction", "",
             f"  function automatic {t} signed [{w - 1}:0] same({t} signed [{w - 1}:0] p);",
             "    return p;", "  endfunction", "",
             f"  task automatic show(input {t} [{w - 1}:0] p);",
             '    $display("task input=%h", p);', "  endtask", "",
             f"  task automatic copy(input {t} [{w - 1}:0] p, output {t} [{w - 1}:0] q);",
             "    q = p;", "  endtask"]
    if not four:
        decls += ["", f"  function automatic void flip_top(ref {t} [{w - 1}:0] p);",
                  f"    p[{w - 1} -: 8] = ~p[{w - 1} -: 8];", "  endfunction"]
    steps, out = [], []
    steps += assign("a", a) + assign("b", b) + assign("s", sv)
    steps += ['    $display("pick(0)=%h", pick(0, a, b));', '    $display("pick(1)=%h", pick(1, a, b));']
    out += [f"pick(0)={a.hex()}", f"pick(1)={b.hex()}"]
    steps += ["    wide = same(s);", '    $display("signed result extended=%h", wide);']
    out.append(f"signed result extended={sv.resize(w + 16, True).hex()}")
    steps += ["    show(a);"]
    out.append(f"task input={a.hex()}")
    steps += ["    copy(b, r);", '    $display("output argument=%h", r);']
    out.append(f"output argument={b.hex()}")
    if not four:
        steps += ["    flip_top(a);", '    $display("after ref=%h", a);']
        top = a.sel(w - 8, 8)
        out.append(f"after ref={a.put(w - 8, V(8, ~top.one)).hex()}")
    comment = (f"IEEE 1800-2023 §13.4.1, §13.3 and §13.5 with {w}-bit {words} values"
               + (" that have x and z in their upper chunk" if four else "")
               + ": a function returns either operand of ?: whole (§11.4.11), a signed "
               "result is sign-extended to a wider target (§10.7), and a task input and an "
               "output argument (§13.5.1) carry every bit"
               + ("." if four else "; a function that inverts the top byte of a ref "
                  "argument (§13.5.2) changes the variable itself."))
    return Case(name, f"Function results, task inputs and output arguments of {w}-bit {words} "
                "values" + ("" if four else ", and a ref argument"),
                "13.4.1 13.3 13.5.1 11.4.11 10.7" + ("" if four else " 13.5.2"), comment,
                module(name, decls, steps), "\n".join(out) + "\n", fourstate=four, chapter=13)


def cases() -> list[Case]:
    out = []
    for w in WIDTHS:
        out.append(values_case(w))
        for four in (False, True):
            out.append(select_case(w, four))
            out.append(ops_case(w, four))
        for four in (False, True):
            out.append(subroutine_case(w, four))
    return out
