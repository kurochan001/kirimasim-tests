"""Independent interval model of ambiguous drive-strength combinations.

28.12.2 and Figures 28-9 through 28-14 define the union of two ambiguous
strength ranges. 28.12.3 instead applies to an unambiguous opposing driver.
All values are calculated before running a simulator.
"""

from common import Case

NAME = "ambiguous_strength_union"
VERSION = 1
CHAPTER = 28
LEVEL = {"weak": 3, "pull": 5, "strong": 6, "supply": 7}
MNEMONIC = {3: "We", 5: "Pu", 6: "St", 7: "Su"}


def value(s0, s1):
    if s0 == s1:
        return MNEMONIC[s0]+"X"
    return f"{s0}{s1}X"


def high_low(zero, one):
    name = f"test_gen_ambig_union_hl_{zero}0_{one}1"
    s0, s1 = LEVEL[zero], LEVEL[one]
    body = f"""`timescale 1ns/1ps
module {name};
  logic hi_en, lo_en;
  wire joined, only_h, only_l;
  bufif1 ({one}1, {one}0) h(joined, 1'b1, hi_en);
  bufif1 ({zero}0, {zero}1) l(joined, 1'b0, lo_en);
  bufif1 ({one}1, {one}0) hp(only_h, 1'b1, hi_en);
  bufif1 ({zero}0, {zero}1) lp(only_l, 1'b0, lo_en);
  initial begin
    hi_en = 1'bx; lo_en = 1'bx;
    #1;
    $display("xx h=%v l=%v joined=%v", only_h, only_l, joined);
    hi_en = 1; lo_en = 0;
    #1;
    $display("10 h=%v l=%v joined=%v", only_h, only_l, joined);
    hi_en = 0; lo_en = 1;
    #1;
    $display("01 h=%v l=%v joined=%v", only_h, only_l, joined);
    hi_en = 0; lo_en = 0;
    #1;
    $display("00 h=%v l=%v joined=%v", only_h, only_l, joined);
    hi_en = 1'bz; lo_en = 1'bz;
    #1;
    $display("zz h=%v l=%v joined=%v", only_h, only_l, joined);
  end
endmodule
"""
    h, l = MNEMONIC[s1]+"H", MNEMONIC[s0]+"L"
    expected = (f"xx h={h} l={l} joined={value(s0,s1)}\n"
                f"10 h={MNEMONIC[s1]}1 l=HiZ joined={MNEMONIC[s1]}1\n"
                f"01 h=HiZ l={MNEMONIC[s0]}0 joined={MNEMONIC[s0]}0\n"
                "00 h=HiZ l=HiZ joined=HiZ\n"
                f"zz h={h} l={l} joined={value(s0,s1)}\n")
    return Case(name=name,
                description=f"ambiguous `{zero}0` L and `{one}1` H drivers combine over both strength ranges",
                lrm="28.12.2 28.6 21.2.1.4",
                comment="IEEE 1800-2023 28.12.2 combines ambiguous strength "
                        "ranges by retaining both extremes and the intervening "
                        "levels, as in Figures 28-9 and 28-10. An unknown control "
                        "on a three-state driver produces H or L (28.6). The "
                        "isolated duplicates show each source range, while the "
                        "joined net shows both extremes with %v (21.2.1.4). "
                        "Both x and z controls are used. Enabled-one-source and "
                        "both-off controls distinguish range union from always "
                        "returning x or from taking only the stronger source. "
                        "The 5.054 release of Verilator does not reproduce "
                        "these four-state strength observations.",
                body=body, expected=expected, fourstate=True)


# Known-value ranges overlap at pull strength in the first two rows and
# over weak..pull in the others. Each is genuinely ambiguous, not a fixed
# strength signal. The first row reproduces the ranges in Figure 28-11
# with different, gate-only circuitry rather than copying its example.
BOUNDED = (("strong", "pull", "pull", "weak"),
           ("pull", "weak", "strong", "pull"),
           ("strong", "weak", "pull", "weak"),
           ("pull", "weak", "strong", "weak"))


def bounded(hmax, hmin, lmax, lmin):
    name = f"test_gen_ambig_union_bounded_h{LEVEL[hmax]}{LEVEL[hmin]}_l{LEVEL[lmax]}{LEVEL[lmin]}"
    body = f"`timescale 1ns/1ps\nmodule {name};\n  logic hi_en, lo_en, force_zero;\n"
    body += "  wire joined, high_range, low_range, overridden, strong_override;\n"
    for target in ("joined", "overridden", "strong_override", "high_range"):
        body += f"  bufif1 ({hmax}1, {hmax}0) h_{target}({target}, 1'b1, hi_en);\n"
        body += f"  pullup ({hmin}1) hp_{target}({target});\n"
    for target in ("joined", "overridden", "strong_override", "low_range"):
        body += f"  bufif1 ({lmax}0, {lmax}1) l_{target}({target}, 1'b0, lo_en);\n"
        body += f"  pulldown ({lmin}0) lp_{target}({target});\n"
    body += "  bufif1 (supply0, supply1) fixed_zero(overridden, 1'b0, force_zero);\n"
    body += "  bufif1 (strong0, strong1) fixed_strong_zero(strong_override, 1'b0, force_zero);\n"
    body += "  initial begin\n    hi_en = 1'bx; lo_en = 1'bx; force_zero = 0;\n    #1;\n"
    body += '    $display("ranges h=%v l=%v joined=%v", high_range, low_range, joined);\n'
    body += "    force_zero = 1;\n    #1;\n"
    body += '    $display("unambiguous supply0=%v strong0=%v joined=%v",\n'
    body += '             overridden, strong_override, joined);\n'
    body += "    force_zero = 0; hi_en = 1'bz; lo_en = 1'bz;\n    #1;\n"
    body += '    $display("z controls h=%v l=%v joined=%v", high_range, low_range, joined);\n'
    body += "  end\nendmodule\n"
    h = f"{LEVEL[hmax]}{LEVEL[hmin]}1"; l = f"{LEVEL[lmax]}{LEVEL[lmin]}0"
    joined = value(LEVEL[lmax], LEVEL[hmax])
    strong = "StX" if LEVEL[hmax] == LEVEL["strong"] else "St0"
    expected = (f"ranges h={h} l={l} joined={joined}\n"
                f"unambiguous supply0=Su0 strong0={strong} joined={joined}\n"
                f"z controls h={h} l={l} joined={joined}\n")
    return Case(name=name,
                description=f"bounded known-one `{h}` and known-zero `{l}` ranges retain both extremes when combined",
                lrm="28.12.2 28.12.3 28.6 28.10 21.2.1.4",
                comment="IEEE 1800-2023 28.12.2, Figures 28-11 through 28-14, "
                        "combines two genuinely ambiguous known-value ranges "
                        "into a range containing both extremes. Each bounded "
                        "range is produced by a weaker constant pull source and "
                        "a stronger three-state source with an unknown control. "
                        "The isolated duplicates expose those ranges with %v. "
                        "The joined network contains both complete source pairs. "
                        "Separate duplicates have enabled supply0 and strong0 drivers: "
                        "28.12.3 then replaces all weaker possible levels and "
                        "gives unambiguous Su0, or StX when the high range reaches "
                        "strong1 and St0 otherwise. This contrast prevents treating "
                        "an unambiguous opposing source by the union rule. "
                        "X and Z controls must give the same ranges. The "
                        "5.054 release of Verilator does not reproduce these "
                        "four-state strength observations.",
                body=body, expected=expected, fourstate=True)


def cases():
    assert set(LEVEL.values()) == {3, 5, 6, 7}
    assert all(LEVEL[a] > LEVEL[b] and LEVEL[c] > LEVEL[d]
               and max(LEVEL[b], LEVEL[d]) <= min(LEVEL[a], LEVEL[c])
               for a, b, c, d in BOUNDED)
    return [high_low(zero, one) for zero in LEVEL for one in LEVEL] + [bounded(*row) for row in BOUNDED]
