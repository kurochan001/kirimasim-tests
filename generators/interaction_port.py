"""Cross module input/output connections with widths, signs and syntax.

23.3.3 treats each input/output connection as a source-to-sink assignment.
The signed source is in the parent for input, in the child for output.
All ports and interconnects are explicit 4-state wire nets. A separate
sample variable makes final 2-state conversion observable after settling.
"""

from common import Case
from interaction_bits import pattern, resize, two_state
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_port"
VERSION = 1
CHAPTER = 23

MODEL = Model(
    "port_connection",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("direction", ("input", "output")), ("sign", ("unsigned", "signed")),
     ("sink_width", ("narrow", "same", "wide")), ("value", ("known", "x", "z")),
     ("sample_state", ("bit", "logic")), ("binding", ("named", "positional")),
     ("declaration", ("ansi", "nonansi"))),
    lambda r: r[0] != "1" or r[3] != "narrow",
    groups=(("width", "value", "sample_state"), ("direction", "sign", "sink_width"),
            ("direction", "binding", "declaration")),
    anchors=(("129", "output", "signed", "wide", "z", "logic", "named", "nonansi"),
             ("65", "input", "signed", "narrow", "x", "bit", "positional", "ansi"),
             ("33", "output", "unsigned", "wide", "known", "logic", "named", "ansi"),
             ("33", "input", "signed", "wide", "x", "bit", "positional", "nonansi"),
             ("32", "input", "signed", "wide", "known", "logic", "named", "ansi")),
    constraints=("幅1のnarrowは除外。ポートと接続線は明示した4状態wire。"
                 "bit/logicは#1後のサンプル変数の型で、ポート自体の型ではない。inout/refは対象外",),
)


def case_name(row: Row) -> str:
    w, direction, sign, relation, value, state, binding, declaration = row
    return (f"test_gen_cross_port_w{w}_{direction[0]}_{sign[0]}_{relation[0]}_"
            f"{value[0]}_{state[0]}_{binding[0]}_{declaration[0]}")


def reference(row: Row) -> tuple[str, str, str]:
    w, _, sign, relation, value, state, *_ = row
    w = int(w)
    sink = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    source = pattern(w, value)
    observed = resize(source, sink, sign == "signed")
    return source, observed, two_state(observed) if state == "bit" else observed


def make_case(row: Row) -> Case:
    w, direction, sign, relation, value, state, binding, declaration = row
    w = int(w)
    sink = w + {"narrow": -1, "same": 0, "wide": 1}[relation]
    source, observed, sample = reference(row)
    name = case_name(row)
    child = name + "_child"
    input_width = sink if direction == "input" else w
    output_width = sink if direction == "input" else w
    output_sign = "unsigned" if direction == "input" else sign
    inputs = f"input wire [{input_width - 1}:0] value"
    outputs = f"output wire {output_sign} [{output_width - 1}:0] observed"
    lines = ["`timescale 1ns/1ns"]
    if declaration == "ansi":
        lines += [f"module {child}(", f"  {inputs},", f"  {outputs}", ");"]
    else:
        lines += [f"module {child}(value, observed);", f"  {inputs};", f"  {outputs};"]
    lines += ["  assign observed = value;", "endmodule", f"module {name};",
              f"  logic {'unsigned' if direction == 'output' else sign} [{w - 1}:0] source;",
              f"  wire [{sink - 1}:0] observed;", f"  {state} [{sink - 1}:0] sample;"]
    connection = ".value(source), .observed(observed)" if binding == "named" else "source, observed"
    lines += [f"  {child} dut(", f"    {connection}", "  );", "  initial begin",
              f"    source = {literal(source)};", "    #1;", "    sample = observed;",
              '    $display("source=%b wire=%b sample=%b", source, observed, sample);',
              "    $finish;", "  end", "endmodule"]
    note = (" With the suite runner's -ginterconnect option, Icarus Verilog 13.0 "
            "zero-pads this signed input connection instead of sign-extending it. "
            "Without that option the same case matches. The expectation follows "
            "23.3.3.8 and 10.7."
            if direction == "input" and sign == "signed" and relation == "wide" else "")
    return Case(
        name, "Port connection width and source sign survive hierarchy and final state conversion",
        "23.3.3 23.3.3.3 23.3.3.8 23.2.2.3 10.7 6.11.2",
        "An input connection resizes the parent's signed/unsigned source into the child; "
        "an output connection resizes the child's signed/unsigned output into the parent. "
        "Both child ports and the observed connection are explicit wire nets. Named and "
        "positional bindings combine with ANSI/non-ANSI declarations. After #1 the "
        "four-state connection is observed and copied into a bit or logic sample variable." + note,
        "\n".join(lines), f"source={source} wire={observed} sample={sample}\n",
        fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
