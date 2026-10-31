"""Wildcard port binding, package visibility, local shadows and input defaults."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_import"
VERSION = 1
CHAPTER = 23

MODEL = Model(
    "port_import_scope",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("sample_state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("import_style", ("wild", "explicit")), ("shadow", ("none", "local")),
     ("binding", ("star", "short", "named", "qualified", "zero"))),
    lambda row: row[3] != "explicit" or row[4] == "none",
    groups=(("width", "sample_state", "value"), ("import_style", "shadow", "binding"),
            ("sample_state", "value", "binding"), ("import_style", "binding", "value"),
            ("shadow", "binding", "value")),
    anchors=(("1", "bit", "known", "wild", "none", "star"),
             ("129", "logic", "z", "wild", "none", "short"),
             ("65", "logic", "x", "explicit", "none", "star"),
             ("33", "bit", "x", "wild", "local", "star"),
             ("32", "logic", "known", "wild", "local", "qualified"),
             ("64", "logic", "known", "wild", "none", "zero")),
    constraints=("明示importと同名の局所宣言の併用180行は26.3で不正なため除外し、合法540行を対象とする。"
                 "すべての接続型・幅を揃え、input/outputは明示した4状態wire。bit/logicは整定後のサンプル型。"
                 "各親に既定値0/全1の2子を置き、別の親スコープの対照は常にwildcard importと.*だけを使う。"
                 ".*だけのスコープに別の無修飾p参照を作らない。default_nettype noneで暗黙netを禁止する。"
                 "空の実引数・幅変換・競合する複数package・inout/refは対象外。未対応による除外なし",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_import_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, str, str]]:
    w = int(row[0])
    patterns = ("0" * w, "1" * w, ("10" * w)[:w])
    result = [(f"k{i}", bits, bits.translate(str.maketrans("01", "10")))
              for i, bits in enumerate(patterns)]
    if row[2] != "known":
        for i, bits in enumerate(patterns):
            data = list(bits)
            for index in {0, w // 2, w - 1}:
                data[index] = row[2]
            raw = "".join(data)
            result.append((f"u{i}", raw, raw.translate(str.maketrans("01xz", "10zx"))))
    return result


def selected_source(row: Row) -> str:
    if row[5] == "zero":
        return "zero"
    if row[5] == "qualified":
        return "package"
    if row[4] == "local":
        return "local"
    if row[3] == "explicit" or row[5] in ("short", "named"):
        return "package"
    return "default"


def sampled(row: Row, bits: str) -> str:
    return bits.translate(str.maketrans("xz", "00")) if row[1] == "bit" else bits


def reference(row: Row) -> str:
    w, route = int(row[0]), selected_source(row)
    zero, one = "0" * w, "1" * w
    output = []
    for label, package, local in phases(row):
        output.append(f"{label} raw={package} package={package} local={local}")
        left, right = ((zero, one) if route == "default" else
                       (zero, zero) if route == "zero" else
                       (local, local) if route == "local" else (package, package))
        for who, a, b in (("dut", left, right), ("guard", zero, one)):
            output.append(f"{label} {who} left_port={a} left={a} left_sample={sampled(row, a)} "
                          f"right_port={b} right={b} right_sample={sampled(row, b)} bits={w}")
    return "\n".join(output) + "\n"


def parent(row: Row, guard: bool = False) -> list[str]:
    width, state, value, import_style, shadow, binding = row
    w = int(width)
    if guard:
        import_style, shadow, binding = "wild", "none", "star"
    name = "port_guard" if guard else "port_parent"
    lines = [f"module {name};", "  import port_source::" + ("*;" if import_style == "wild" else "p;"),
             f"  localparam logic [{w-1}:0] FALLBACK = {literal(('10' * w)[:w])};",
             f"  wire [{w-1}:0] left, right;"]
    if shadow == "local":
        lines += [f"  logic [{w-1}:0] p;"]
    argument = {"star": "", "short": ".p, ", "named": ".p(p), ",
                "qualified": ".p(port_source::p), ", "zero": ".p('0), "}[binding]
    lines += [f"  port_leaf #(.FALLBACK('0)) lo(.y(left), {argument}.*);",
              f"  port_leaf #(.FALLBACK('1)) hi(.y(right), {argument}.*);", "endmodule"]
    return lines


def snapshot(label: str, who: str) -> list[str]:
    owner = "dut" if who == "dut" else "control"
    return [f"    left_sample = {owner}.left; right_sample = {owner}.right;",
            f'    $write("{label} {who} left_port=%b left=%b left_sample=%b",',
            f"           {owner}.lo.p, {owner}.left, left_sample);",
            '    $write(" right_port=%b right=%b right_sample=%b",',
            f"           {owner}.hi.p, {owner}.right, right_sample);",
            f'    $display(" bits=%0d", $bits({owner}.lo.p));']


def make_case(row: Row) -> Case:
    width, state, value, import_style, shadow, binding = row
    w, name = int(width), case_name(row)
    lines = ["`timescale 1ns/1ns", "`default_nettype none", "package port_source;",
             f"  logic [{w-1}:0] p = '0;", "endpackage", "module port_leaf #(",
             f"  parameter logic [{w-1}:0] FALLBACK = '0", ")(",
             f"  input wire [{w-1}:0] p = FALLBACK,", f"  output wire [{w-1}:0] y", ");",
             "  assign y = p;", "endmodule", "module port_writer;", "  import port_source::p;",
             f"  task automatic drive(input logic [{w-1}:0] value);", "    p = value;",
             "  endtask", "endmodule", *parent(row), *parent(row, guard=True),
             f"module {name};", "  port_parent dut();", "  port_guard control();",
             "  port_writer writer();",
             f"  logic [{w-1}:0] raw, local_stimulus;", f"  {state} [{w-1}:0] left_sample, right_sample;",
             "  initial begin"]
    for label, package, local in phases(row):
        lines += [f"    raw = {literal(package)};", "    writer.drive(raw);",
                  f"    local_stimulus = {literal(local)};"]
        if shadow == "local":
            lines += ["    dut.p = local_stimulus;"]
        observed_local = "dut.p" if shadow == "local" else "local_stimulus"
        lines += ["    #1;", f'    $display("{label} raw=%b package=%b local=%b",',
                  f"             raw, port_source::p, {observed_local});", *snapshot(label, "dut"),
                  *snapshot(label, "guard")]
    lines += ["    $finish;", "  end", "endmodule", "`default_nettype wire"]
    return Case(
        name, "Package import visibility and local shadows determine wildcard port binding and defaults",
        "23.3.2.4 26.3 23.2.2.4 23.3.2.3 6.11.2 22.8",
        "Two child input ports use defaults zero/all-one, so selecting a live "
        "source cannot accidentally match both defaults. A wildcard package "
        "import alone does not make p visible to .*; explicit import, .p or "
        ".p(p) does. A local p shadows a wildcard import; a qualified actual "
        "bypasses it. An explicit zero overrides defaults. A separate guard "
        "scope always has only wildcard import and .*, and must keep its "
        "defaults even when the tested scope references p. There are no "
        "other unqualified p references in those parent scopes. A separate "
        "writer scope explicitly imports p and updates it through a task. Package and "
        "local four-state sources change through known and X/Z phases; "
        "input ports, output nets, widths and bit/logic samples are observed "
        "after settling. The parents also declare a different FALLBACK name; "
        "default input constants belong to the child scope. All connection "
        "types and widths match; bit/logic is only the final sample type. "
        "Explicit import plus a conflicting local p is excluded as illegal. "
        "Implicit nets, empty actuals, width conversion and competing "
        "packages are outside this model.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
