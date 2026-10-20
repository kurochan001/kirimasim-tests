"""Generates tests of how the values and strengths of two drivers of a net
resolve (IEEE 1800-2023 28.11, 28.12 and 6.6), shown with %v and %b.

The reference model gives each driver the set of values it can drive, as a
value (0, 1, x or z) and a strength level from Table 28-7: a continuous
assignment drives 0 at its strength0 and 1 at its strength1 (10.3.4), z for
a highz strength, and for x both of them; a bufif gate with an unknown
control drives L or H, its value or z (Table 28-5). Two values combine as in
28.12.1: z gives way to anything, the stronger value wins, equal values stay,
and equal strengths of opposite values give x on a wire, the AND of them on
wand and triand, and their OR on wor and trior (28.12.4). The result is the
set of the combinations of every value of one driver with every value of the
other, which is how 28.12.4 combines ambiguous strengths and gives the ranges
of 28.12.2. tri0 and tri1 nets add a pull 0 or pull 1 driver (6.6.5).

%v then shows the result as 21.2.1.4 says: a mnemonic when the strength is a
single level, else two digits, the largest and smallest levels of a 0 or a 1,
or the largest 0 and 1 levels of an x; L and H take the mnemonic of their
largest level.

On a wire, 28.12.3 combines a driver with a single known value and strength
with an ambiguous one by removing the ambiguous levels at or below the known
one. Where that and the combinations above could differ, which is when the
ambiguous driver has a level equal to the known one with the opposite value,
the case is left out.
"""

import random

from common import Case

NAME = "strength"
VERSION = 1
CHAPTER = 28

LEVELS = {"supply": 7, "strong": 6, "pull": 5, "weak": 3, "highz": 0}
MNEMONIC = {7: "Su", 6: "St", 5: "Pu", 4: "La", 3: "We", 2: "Me", 1: "Sm", 0: "Hi"}


def driven(value: str, s0: int, s1: int) -> set[tuple[str, int]]:
    """What a continuous assignment with strengths (s0, s1) drives for value."""
    out = set()
    if value in "0x":
        out.add(("0", s0) if s0 else ("z", 0))
    if value in "1x":
        out.add(("1", s1) if s1 else ("z", 0))
    if value == "z":
        out.add(("z", 0))
    return out


def bufif(data: str, control: str, active: str, s0: int, s1: int) -> set[tuple[str, int]]:
    """What bufif1 (active "1") or bufif0 (active "0") with strengths (s0, s1)
    drives, from Table 28-5: its data (x for z) when the control is active, z
    when it is not, and for an unknown control L or H (the value or z), or x
    when the data is unknown too."""
    value = data if data in "01" else "x"
    if control in "01":
        return driven(value, s0, s1) if control == active else {("z", 0)}
    if value == "x":
        return driven("x", s0, s1)
    return driven(value, s0, s1) | {("z", 0)}


def wired(a: str, b: str, kind: str) -> str:
    if kind == "and":
        return "0" if "0" in (a, b) else "1" if a == b == "1" else "x"
    if kind == "or":
        return "1" if "1" in (a, b) else "0" if a == b == "0" else "x"
    return "x"


def combine(a: tuple[str, int], b: tuple[str, int], kind: str) -> tuple[str, int]:
    (va, la), (vb, lb) = a, b
    if va == "z":
        return b
    if vb == "z":
        return a
    if la != lb:
        return a if la > lb else b
    return (va, la) if va == vb else (wired(va, vb, kind), la)


def resolve(signals: list[set], kind: str) -> set[tuple[str, int]]:
    result = signals[0]
    for s in signals[1:]:
        result = {combine(a, b, kind) for a in result for b in s}
    return result


def unclear(a: set, b: set) -> bool:
    """Whether 28.12.3's rules for a known driver and an ambiguous one could
    give another result than the combinations, on a wire."""
    for known, other in ((a, b), (b, a)):
        if len(known) == 1 and next(iter(known))[0] in "01" and \
                (len(other) > 1 or any(v == "x" for v, _ in other)):
            v, level = next(iter(known))
            if any(l == level and w != v and w != "z" for w, l in other):
                return True
    return False


def show(result: set[tuple[str, int]]) -> str:
    """%v and %b of a resolved net."""
    zero = [l for v, l in result if v in "0x"]
    one = [l for v, l in result if v in "1x"]
    has_z = any(v == "z" for v, _ in result)
    if not zero and not one:
        return "HiZ z"
    if zero and one:
        m0, m1 = max(zero), max(one)
        return (f"{MNEMONIC[m0]}X" if m0 == m1 else f"{m0}{m1}X") + " x"
    levels, value = (zero, "0") if zero else (one, "1")
    if has_z:
        return f"{MNEMONIC[max(levels)]}{'L' if value == '0' else 'H'} x"
    hi, lo = max(levels), min(levels)
    return (f"{MNEMONIC[hi]}{value}" if hi == lo else f"{hi}{lo}{value}") + f" {value}"


def strength_text(s0: int, s1: int) -> str:
    name = {v: k for k, v in LEVELS.items()}
    return f"({name[s0]}0, {name[s1]}1)"


NETS = {"wire": "", "tri": "", "wand": "and", "triand": "and", "wor": "or", "trior": "or",
        "tri0": "", "tri1": ""}
STRENGTHS = [(7, 7), (6, 6), (5, 5), (3, 3), (6, 5), (5, 6), (6, 3), (3, 6), (5, 3), (3, 5),
             (7, 3), (0, 6), (6, 0), (0, 5), (5, 0), (7, 6), (6, 7)]


def net_cases(rng: random.Random) -> list[Case]:
    cases = []
    for net, kind in NETS.items():
        pull = [{("0", 5)}] if net == "tri0" else [{("1", 5)}] if net == "tri1" else []
        values = "01z" if pull else "01xz"
        pairs = [(a, b) for a in STRENGTHS for b in STRENGTHS]
        rng.shuffle(pairs)
        if kind:
            # Wired nets: two cases with equal strengths, where the values are
            # combined by the logic function, and six with unequal ones.
            equal = [(a, a) for a in STRENGTHS if 0 not in a]
            pairs = rng.sample(equal, 2) + [(a, b) for a, b in pairs if a != b]
        total = 8 if kind else 22
        count = 0
        for p, q in pairs:
            if count == total:
                break
            lines, out = [], []
            for d1 in values:
                for d2 in values:
                    a, b = driven(d1, *p), driven(d2, *q)
                    if not kind and unclear(a, b):
                        continue
                    lines.append(f"    d1 = 1'b{d1}; d2 = 1'b{d2};")
                    lines.append('    #1 $display("%v %b", n, n);')
                    out.append(show(resolve([a, b] + pull, kind)))
            if len(out) < 8:
                continue
            count += 1
            name = f"test_gen_strength_{net}_{count:02d}"
            rule = {"": "the stronger value wins, and equal strengths of opposite values give "
                        "x with that strength",
                    "and": "the stronger value wins, and at equal strengths the values are "
                           "combined by AND (28.12.4)",
                    "or": "the stronger value wins, and at equal strengths the values are "
                          "combined by OR (28.12.4)"}[kind]
            extra = (f" A {net} net has a pull {net[-1]} driver of its own (6.6.5)."
                     if pull else "")
            comment = (f"IEEE 1800-2023 §28.12: two continuous assignments drive the {net} "
                       f"net n, with strengths {strength_text(*p)} and {strength_text(*q)} "
                       f"(10.3.4); {rule}. An x driver drives both of its strengths, and a "
                       f"highz strength drives z. %v shows the strength and value of n "
                       f"(21.2.1.4) and %b its value.{extra}")
            body = "\n".join([f"module {name};", "  logic d1, d2;", f"  {net} n;",
                              f"  assign {strength_text(*p)} n = d1;",
                              f"  assign {strength_text(*q)} n = d2;", "",
                              "  initial begin"] + lines + ["  end", "endmodule"])
            cases.append(Case(name, f"Two drivers of a {net} net with strengths "
                                    f"{strength_text(*p)} and {strength_text(*q)} resolve to "
                                    f"the value and strength that 28.12 gives",
                              "28.12 28.12.1 28.12.2 28.11 21.2.1.4"
                              + (" 28.12.4" if kind else "") + (" 6.6.5" if pull else ""),
                              comment, body, "\n".join(out) + "\n", fourstate=True))
    return cases


def bufif_cases(rng: random.Random) -> list[Case]:
    cases = []
    for i in range(16):
        gate = "bufif1" if i % 2 == 0 else "bufif0"
        active = gate[-1]
        g = rng.choice([(6, 6), (5, 5), (6, 5), (3, 6), (7, 5)])
        q = rng.choice([(5, 5), (3, 3), (6, 3), (3, 6), (5, 3)])
        lines, out = [], []
        for data in "01x":
            for control in "01x":
                for d2 in "01z":
                    a = bufif(data, control, active, *g)
                    b = driven(d2, *q)
                    if unclear(a, b):
                        continue
                    lines.append(f"    data = 1'b{data}; en = 1'b{control}; d2 = 1'b{d2};")
                    lines.append('    #1 $display("%v %b", n, n);')
                    out.append(show(resolve([a, b], "")))
        name = f"test_gen_strength_{gate}_{i // 2 + 1:02d}"
        comment = (f"IEEE 1800-2023 §28.6, §28.12.2: a {gate} gate with strengths "
                   f"{strength_text(*g)} and a continuous assignment with strengths "
                   f"{strength_text(*q)} drive the wire n. With an unknown control the gate "
                   f"drives L or H (its value or z, Table 28-5), whose strengths combine with "
                   f"the other driver into a range; %v shows ranges as in 21.2.1.4.")
        body = "\n".join([f"module {name};", "  logic data, en, d2;", "  wire n;",
                          f"  {gate} {strength_text(*g)} g(n, data, en);",
                          f"  assign {strength_text(*q)} n = d2;", "",
                          "  initial begin"] + lines + ["  end", "endmodule"])
        cases.append(Case(name, f"A {gate} gate with an unknown control drives L or H, which "
                                f"combines with another driver into a range of strengths",
                          "28.12.2 28.6 28.12.3 21.2.1.4", comment, body, "\n".join(out) + "\n",
                          fourstate=True))
    return cases


def cases() -> list[Case]:
    rng = random.Random(f"{NAME}@{VERSION}")
    return net_cases(rng) + bufif_cases(rng)
