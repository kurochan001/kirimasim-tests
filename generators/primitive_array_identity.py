"""Observe primitive-array cardinality and declared labels through VPI.

This supplements value-only arrays with actual indices, parent/index lookup
identity and per-element terminal values. VPI iteration order and element
names are not fixed, so the C helper sorts by vpiIndex without printing names.
"""

from common import Case

NAME = "primitive_array_identity"
VERSION = 1
CHAPTER = 28
RANGES = {"descending": (3,0), "ascending": (0,3),
          "negative_up": (-4,-1), "negative_down": (-1,-4), "singleton": (7,7)}
KINDS = {"gate": "buf", "switch": "nmos", "udp": "identity_udp"}


def reference(kind, left, right):
    width = abs(left-right)+1
    patterns = (1,0,1) if width == 1 else (9,6,12)
    lines = []
    for phase, value in enumerate(patterns):
        lines += [f"p{phase} kind={kind} range={left}:{right} size={width}",
                  f"elements={width} duplicate=0"]
        for index in range(min(left,right),max(left,right)+1):
            bit = (value >> abs(index-right)) & 1
            tail = f" t0={bit} t1={bit}" + (" t2=1" if kind == "switch" else "")
            lines.append(f"index={index} parent=1 lookup=1 terms={3 if kind=='switch' else 2}"+tail)
        lines.append("scalar present=1 index_null=1")
    return "\n".join(lines)+"\n"


def case(kind, interval):
    left,right=RANGES[interval]
    width=abs(left-right)+1
    name=f"test_gen_prim_identity_{kind}_{interval}"
    lines=[]
    if kind=="udp":
        lines += ["primitive identity_udp(output y, input a);", "  table",
                  "    0 : 0;", "    1 : 1;", "    x : x;", "  endtable", "endprimitive"]
    lines += ["`timescale 1ns/1ps",f"module {name};",f"  reg [{width-1}:0] a;",
              f"  wire [{width-1}:0] y;", "  wire scalar_y;"]
    extra=", 1'b1" if kind=="switch" else ""
    primitive=KINDS[kind]
    lines += [f"  {primitive} g[{left}:{right}](y, a{extra});",
              f"  {primitive} scalar(scalar_y, a[0]{extra});", "  initial begin"]
    for value in ((1,0,1) if width==1 else (9,6,12)):
        lines += [f"    a = {width}'b{value:0{width}b};", "    #1;", "    $primitive_array_identity;"]
    lines += ["  end", "endmodule"]
    return Case(name=name,
                description=f"a `{kind}` array exposes its declared `{left}:{right}` indices, element identity and terminal values",
                lrm="28.3.5 28.3.6 37.11 37.35 38.3 38.19 38.21",
                comment="IEEE 1800-2023 28.3.5 defines the instance count and "
                        "allows nonzero, negative, ascending and equal range "
                        "endpoints. VPI instance-array and primitive models "
                        "(37.11 and 37.35) expose bounds, size, actual indices, "
                        "parent-array relations and primitive terminals. The "
                        "helper sorts actual indices, compares parent and "
                        "indexed-lookup handles, detects duplicate identities "
                        "and reads each indexed element's input/output values "
                        "for three patterns. Thus vector equality alone cannot "
                        "hide a wrong instance count or index-to-bit mapping. "
                        "An ordinary scalar primitive has no array index. "
                        "Iterator order and element names are not observed. "
                        "Current fixed releases do not reproduce this VPI "
                        "observation; no simulator oracle is registered.",
                body="\n".join(lines)+"\n",expected=reference(kind,left,right),
                fourstate=kind=="switch",
                extra={"vpi_c":"@../../ch28/primitive_array_identity.c"})


def cases():
    assert set(abs(l-r)+1 for l,r in RANGES.values())=={1,4}
    return [case(k,r) for k in KINDS for r in RANGES]
