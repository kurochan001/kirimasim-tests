"""Primitive-array terminal widths and nonzero/negative instance ranges.

The width rule of 28.3.6 permits a scalar broadcast or exactly one bit per
primitive. Two and five bits are therefore invalid for a four-instance
array. Legal companion cases exercise both broadcasts and vector partition.
"""

from common import Case

NAME = "primitive_array_bounds"
VERSION = 1
CHAPTER = 28
GATES = {"and": 3, "xnor": 3, "not": 2, "bufif1": 3, "nmos": 3}
TRUTH_CLAUSE = {"and": "28.4", "xnor": "28.4", "not": "28.5",
                "bufif1": "28.6", "nmos": "28.7"}
RANGES = {"negative_up": (-3, 0), "negative_down": (0, -3)}
# Actual acceptances are recorded after running the final rendered cases.
ACCEPTED_BY_5054 = {(gate, "y") for gate in GATES}
UNSUPPORTED_BY_5054 = set()


def terminal_names(gate):
    return ("y", "a") if GATES[gate] == 2 else ("y", "a", "b")


def invalid(gate, role, width, direction):
    name = f"test_gen_primarray_bad_{gate}_{role}_w{width}_{direction}"
    names = terminal_names(gate)
    widths = {n: (width if n == role else 4) for n in names}
    left, right = RANGES[direction]
    note = ""
    if (gate, role) in ACCEPTED_BY_5054:
        note = "// The 5.054 release of Verilator accepts this width mismatch.\n"
    if (gate, role) in UNSUPPORTED_BY_5054:
        note = "// The 5.054 release of Verilator reports an unsupported primitive.\n"
    body = note + f"module {name};\n"
    body += "".join(f"  wire [{widths[n]-1}:0] {n};\n" for n in names)
    body += f"  {gate} g[{left}:{right}]({', '.join(names)});  // illegal\nendmodule\n"
    return Case(name=name,
                description=f"a `{gate}` array rejects a `{width}`-bit `{role}` terminal for four instances",
                lrm="28.3.6 28.3.5",
                comment="IEEE 1800-2023 28.3.6 permits a scalar terminal expression "
                        "to be broadcast to every primitive, or partitions a vector "
                        "into one bit per primitive. Any other bit count is an error. "
                        f"The range [{left}:{right}] contains four instances (28.3.5). "
                        f"Only terminal {role} has {width} bits; all other terminals "
                        "have four. Its width is neither one nor four, and the "
                        "marked declaration is the sole violation. The companion "
                        "legal tests exercise scalar and four-bit connections.",
                body=body, expected="",
                should_fail_because=f"terminal {role} has {width} bits for a four-instance {gate} array")


def truth(gate, a, b):
    return {"and": lambda: a & b, "xnor": lambda: 1 ^ a ^ b,
            "not": lambda: 1 ^ a, "bufif1": lambda: str(a) if b else "z",
            "nmos": lambda: str(a) if b else "z"}[gate]()


def vector(gate, a, b):
    return "".join(str(truth(gate, int(x), int(y))) for x, y in zip(a, b))


def legal(gate):
    name = f"test_gen_primarray_legal_{gate}_range_boundaries"
    names = terminal_names(gate)
    body = f"`timescale 1ns/1ps\nmodule {name};\n"
    body += "  logic [3:0] a, b;\n  logic scalar_a, scalar_b;\n"
    body += "  wire [3:0] up, down, offset, broadcast;\n  wire single;\n"
    for output, interval in (("up", "[-3:0]"), ("down", "[0:-3]"), ("offset", "[9:6]")):
        args = [output, "a"] + (["b"] if len(names) == 3 else [])
        body += f"  {gate} g_{output}{interval}({', '.join(args)});\n"
    args = ["broadcast", "scalar_a"] + (["scalar_b"] if len(names) == 3 else [])
    body += f"  {gate} g_broadcast[-2:1]({', '.join(args)});\n"
    args = ["single", "scalar_a"] + (["scalar_b"] if len(names) == 3 else [])
    body += f"  {gate} g_single[5:5]({', '.join(args)});\n  initial begin\n"
    phases = (("1010", "1100", 0, 0), ("0101", "0011", 1, 1),
              ("0110", "1010", 0, 1), ("1001", "0101", 1, 0))
    expected = []
    for i, (a, b, sa, sb) in enumerate(phases):
        body += f"    a = 4'b{a}; b = 4'b{b}; scalar_a = {sa}; scalar_b = {sb};\n    #1;\n"
        body += f'    $display("p{i} up=%b down=%b offset=%b broadcast=%b single=%b",\n'
        body += "             up, down, offset, broadcast, single);\n"
        y = vector(gate, a, b); one = str(truth(gate, sa, sb))
        expected.append(f"p{i} up={y} down={y} offset={y} broadcast={one*4} single={one}")
    body += "  end\nendmodule\n"
    limitation = ("// The 5.054 release of Verilator does not reproduce disabled z outputs.\n"
                  if gate in ("bufif1", "nmos") else "")
    return Case(name=name,
                description=f"`{gate}` arrays allow negative, descending, nonzero and equal range endpoints with scalar broadcasts",
                lrm=f"28.3.5 28.3.6 {TRUTH_CLAUSE[gate]}",
                comment="IEEE 1800-2023 28.3.5 makes abs(left-right)+1 primitive "
                        "instances, permits either direction and nonzero endpoints, "
                        "and makes one instance when the endpoints are equal. "
                        "Three four-instance arrays cover ascending negative, "
                        "descending negative and positive offset ranges. A fourth "
                        "array broadcasts scalar inputs, and [5:5] is a singleton. "
                        "Four changing input patterns check every output bit after "
                        "settling, including disabled switches and truth-table "
                        f"contrasts. The truth table follows {TRUTH_CLAUSE[gate]}.",
                body=limitation+body, expected="\n".join(expected)+"\n", fourstate=gate in ("bufif1", "nmos"))


def cases():
    assert sum(GATES.values()) == 14
    assert all(abs(left-right)+1 == 4 for left, right in RANGES.values())
    return [invalid(gate, role, width, direction)
            for gate in GATES for role in terminal_names(gate)
            for width in (2, 5) for direction in RANGES] + [legal(gate) for gate in GATES]
