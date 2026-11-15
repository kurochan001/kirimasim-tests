"""Exercise explicit and default strengths of gate primitives (IEEE 1800-2023).

Table 28-2 is cross-checked against the applicable categories of Table 28-1.
The four explicit-strength cases fill the previously unobserved nand, or,
xnor and xor cells. The default case covers every gate in Table 28-2,
including the pull-source exception of 28.10. Truth values come from 28.4
through 28.6; strength mnemonics come from 21.2.1.4.
"""

from common import Case

NAME = "gate_strength_truth"
VERSION = 1
CHAPTER = 28

TABLE_28_2 = set("and nand buf not pulldown or nor bufif0 notif0 pullup "
                 "xor xnor bufif1 notif1".split())
CATEGORIES_28_1 = {
    "n_input": set("and nand nor or xnor xor".split()),
    "n_output": {"buf", "not"},
    "three_state": set("bufif0 bufif1 notif0 notif1".split()),
    "pull": {"pulldown", "pullup"},
}

# Outputs for the input pairs 00, 01, 10, 11, in that order (28.4).
TRUTH = {
    "and": (0, 0, 0, 1), "nand": (1, 1, 1, 0),
    "or": (0, 1, 1, 1), "nor": (1, 0, 0, 0),
    "xor": (0, 1, 1, 0), "xnor": (1, 0, 0, 1),
}
EXPLICIT = ("nand", "or", "xnor", "xor")


def check_model() -> None:
    assert set().union(*CATEGORIES_28_1.values()) == TABLE_28_2
    assert set(TRUTH) == CATEGORIES_28_1["n_input"]
    assert set(EXPLICIT) <= TABLE_28_2
    assert all(len(values) == 4 and set(values) == {0, 1} for values in TRUTH.values())


def explicit(gate: str) -> Case:
    name = f"test_gen_gate_strength_{gate}_asymmetric"
    expected = "".join(
        f"ab={index:02b} weak0_pull1={'Pu1' if value else 'We0'} "
        f"supply1_pull0={'Su1' if value else 'Pu0'}\n"
        for index, value in enumerate(TRUTH[gate]))
    body = f"""`timescale 1ns/1ps
module {name};
  bit a, b;
  wire first, second;
  {gate} (weak0, pull1) first_gate(first, a, b);
  {gate} (supply1, pull0) second_gate(second, a, b);

  initial begin
    for (int pair = 0; pair < 4; pair++) begin
      a = pair[1];
      b = pair[0];
      #1;
      $display("ab=%b%b weak0_pull1=%v supply1_pull0=%v", a, b, first, second);
    end
  end
endmodule
"""
    return Case(
        name=name,
        description=f"{gate} applies both components of two asymmetric drive-strength pairs "
                    "for every binary input pair",
        lrm="28.3.2 28.4 21.2.1.4",
        comment=f"IEEE 1800-2023 28.3.2, Table 28-2, permits a drive strength on {gate}. "
                "The strength0 and strength1 components determine the strengths of its "
                "0 and 1 outputs, and either component may be written first. Two gates "
                "drive separate, otherwise undriven scalar nets with (weak0, pull1) and "
                "(supply1, pull0). All four binary input pairs exercise the truth table "
                "of 28.4 and both strength components of both gates. After propagation "
                "has settled, %v (21.2.1.4) must show We0/Pu1 and Pu0/Su1 respectively. "
                "Ignoring the strength specification or swapping its components changes "
                "the output even when the Boolean value is right.",
        body=body, expected=expected, fourstate=True)


def defaults() -> Case:
    name = "test_gen_gate_default_strengths_all_types"
    logic_order = ("and", "nand", "or", "nor", "xor", "xnor")
    # Keep generated code within the suite's line-width limit.
    declarations = ["  wire " + ", ".join("y_" + gate for gate in logic_order) + ";",
                    "  wire y_buf, y_not, y_bufif0, y_bufif1, y_notif0, y_notif1;",
                    "  wire y_pulldown, y_pullup;"]
    declarations += [f"  {gate} g_{gate}(y_{gate}, a, b);" for gate in logic_order]
    declarations += ["  buf g_buf(y_buf, a);", "  not g_not(y_not, a);"]
    declarations += [f"  {gate} g_{gate}(y_{gate}, a, en);"
                     for gate in ("bufif0", "bufif1", "notif0", "notif1")]
    declarations += ["  pulldown g_pulldown(y_pulldown);", "  pullup g_pullup(y_pullup);"]
    expected = []
    for vector in range(8):
        a, b, en = (vector >> 2) & 1, (vector >> 1) & 1, vector & 1
        label = f"ab={a}{b} en={en}"
        expected.append(label + " logic=" + " ".join(
            f"St{TRUTH[gate][2 * a + b]}" for gate in logic_order))
        tristate = [f"St{a}" if en == 0 else "HiZ",
                    f"St{a}" if en == 1 else "HiZ",
                    f"St{1-a}" if en == 0 else "HiZ",
                    f"St{1-a}" if en == 1 else "HiZ"]
        expected.append(label + f" unary=St{a} St{1-a} tristate=" + " ".join(tristate))
        expected.append(label + " pulls=Pu0 Pu1")
    body = (f"`timescale 1ns/1ps\nmodule {name};\n  bit a, b, en;\n" +
            "\n".join(declarations) + """

  initial begin
    for (int vector = 0; vector < 8; vector++) begin
      a = vector[2];
      b = vector[1];
      en = vector[0];
      #1;
      $display("ab=%b%b en=%b logic=%v %v %v %v %v %v", a, b, en,
               y_and, y_nand, y_or, y_nor, y_xor, y_xnor);
      $display("ab=%b%b en=%b unary=%v %v tristate=%v %v %v %v", a, b, en,
               y_buf, y_not, y_bufif0, y_bufif1, y_notif0, y_notif1);
      $display("ab=%b%b en=%b pulls=%v %v", a, b, en, y_pulldown, y_pullup);
    end
  end
endmodule
""")
    return Case(
        name=name,
        description="every ordinary gate uses strong0/strong1 by default, while pullup "
                    "and pulldown use pull strength",
        lrm="28.3.2 28.4 28.5 28.6 28.10 21.2.1.4",
        comment="IEEE 1800-2023 28.3.2 gives ordinary gates default strong0/strong1 "
                "drive strengths. Pull sources instead default to pull strength (28.10). "
                "One instance of every gate in Table 28-2 has no explicit strength and "
                "drives its own scalar net. All binary data/control triples exercise "
                "each ordinary gate's 0 and 1 outputs; disabled three-state gates drive "
                "z (28.4 through 28.6). %v (21.2.1.4) therefore shows St0 or St1 for "
                "enabled ordinary gates, HiZ when disabled, and Pu0/Pu1 for pull "
                "sources. A default weak/pull drive on an ordinary gate, or strong "
                "drive on a pull source, changes the output without changing its bit.",
        body=body, expected="\n".join(expected) + "\n", fourstate=True)


def cases() -> list[Case]:
    check_model()
    return [*(explicit(gate) for gate in EXPLICIT), defaults()]
