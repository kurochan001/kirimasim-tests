"""Configuration parameter precedence, selective resets and generated shape."""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_config"
VERSION = 1
CHAPTER = 33

MODEL = Model(
    "configuration_generated_shape",
    (("base_width", ("1", "32", "33", "64", "65", "129")),
     ("prior", ("default", "instance", "defparam", "both")),
     ("action", ("set", "reset_w", "reset_all")), ("mode", ("0", "1", "2")),
     ("form", ("if", "case")), ("rhs", ("literal", "local", "parent")),
     ("hierarchy", ("direct", "wrapped"))),
    lambda row: row[2] == "set" or (row[3] == "0" and row[5] == "literal"),
    groups=(("prior", "action", "hierarchy"), ("action", "mode", "form"),
            ("action", "rhs", "hierarchy"), ("base_width", "action", "form")),
    anchors=(("1", "default", "set", "0", "if", "literal", "direct"),
             ("129", "both", "set", "2", "case", "parent", "wrapped"),
             ("65", "defparam", "reset_w", "0", "if", "literal", "wrapped"),
             ("33", "instance", "reset_all", "0", "case", "literal", "direct"),
             ("32", "both", "reset_w", "0", "case", "literal", "direct"),
             ("64", "instance", "set", "1", "if", "local", "wrapped")),
    constraints=("全直積2592行のうち、resetで使わないmode/rhsは0/literalに代表させ、1536行の重複を省いて1056行とする。"
                 "全行は合法で未対応による除外なし。configは通常のmodule階層にあるtargetのW/MODEを設定し、"
                 "そのパラメータでgenerateの幅・個数・分岐を決める。reset_wはWだけ、reset_allは全パラメータを既定値へ戻す。"
                 "対照guardはconfig/defparamの対象外。RHSは数値・config localparam・通常の親moduleパラメータのみ。"
                 "generate内部へのconfig参照、セル置換、ライブラリ差替え、未知値パラメータは対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_config_" + "_".join(row)


def parameters(row: Row) -> tuple[dict, dict]:
    base, prior, action, mode, form, rhs, hierarchy = row
    b = int(base)
    target = {"ID": 0, "W": b, "N": 2, "MODE": 0, "TAG": 10}
    if prior in ("instance", "both"):
        target.update(W=b+1, N=3, MODE=1, TAG=20)
    if prior in ("defparam", "both"):
        target.update(W=b+2, N=1, MODE=2, TAG=30)
    if action == "set":
        offset = {"literal": 0, "local": 1, "parent": 2}[rhs]
        target.update(W=b+3+offset, MODE=(int(mode)+offset) % 3)
    elif action == "reset_w":
        target["W"] = b
    else:
        target = {"ID": 0, "W": b, "N": 2, "MODE": 0, "TAG": 10}
    return target, {"ID": 1, "W": b+6, "N": 3, "MODE": 2, "TAG": 40}


def word(width: int, identity: int, lane: int, phase: int) -> str:
    return "".join(str((((identity+1)*2048 + (lane+1)*256 + bit+1) >> phase) & 1)
                   for bit in range(width-1, -1, -1))


def transformed(bits: str, tag: int, lane: int, mode: int) -> str:
    width = len(bits)
    mask = (tag+lane) ^ (3 if mode == 2 else 0)
    if mode == 1:
        mask ^= (1 << width)-1
    return "".join(str(int(bit) ^ ((mask >> (width-1-i)) & 1)) for i, bit in enumerate(bits))


def reference(row: Row) -> str:
    contexts = parameters(row)
    lines = []
    for phase in range(13):
        for p in contexts:
            identity, width, count, mode, tag = (p[k] for k in ("ID", "W", "N", "MODE", "TAG"))
            lines.append(f"id={identity} p={phase} W={width} N={count} MODE={mode} TAG={tag}")
            for lane in range(count):
                raw = word(width, identity, lane, phase)
                value = transformed(raw, tag, lane, mode)
                lines.append(f"id={identity} p={phase} lane={lane} raw={raw} value={value} "
                             f"branch={mode} bits={width},{width}")
    return "\n".join(lines) + "\n"


def instance_lines(row: Row) -> list[str]:
    b, prior = int(row[0]), row[1]
    overrides = f"#(.W({b+1}), .N(3), .MODE(1), .TAG(20)) " if prior in ("instance", "both") else ""
    return [f"  cfg_leaf {overrides}target();",
            f"  cfg_leaf #(.ID(1), .W({b+6}), .N(3), .MODE(2), .TAG(40)) guard();"]


def config_lines(row: Row) -> list[str]:
    b, prior, action, mode, form, rhs, hierarchy = row
    parent = "cfg_top.box" if hierarchy == "wrapped" else "cfg_top"
    lines = ["config cfg;"]
    if rhs == "local":
        lines += [f"  localparam PW = {int(b)+4}, PM = {(int(mode)+1)%3};"]
    lines += ["  design work.cfg_top;", "  default liblist work;"]
    if action == "set":
        w, m = ((str(int(b)+3), mode) if rhs == "literal" else ("PW", "PM") if rhs == "local"
                else (parent + ".PW", parent + ".PM"))
        values = f"#(.W({w}), .MODE({m}))"
    else:
        values = "#(.W())" if action == "reset_w" else "#()"
    lines += [f"  instance {parent}.target use {values};", "endconfig"]
    return lines


def route(mode: int) -> list[str]:
    return ["begin : route", f"  cfg_lane #(.W(W), .TAG(TAG), .INDEX(i), .OP({mode})) u(",
            "    .raw(raw[i]), .value(value[i]), .width_code(width_code[i]));",
            f"  assign branch_code[i] = {mode};", "end"]


def make_case(row: Row) -> Case:
    base, prior, action, mode, form, rhs, hierarchy = row
    b = int(base)
    lines = ["`timescale 1ns/1ns", "module cfg_lane #(parameter int W = 1, TAG = 0, INDEX = 0, OP = 0)(",
             "  input wire [W-1:0] raw, output wire [W-1:0] value, output wire [31:0] width_code);",
             "  wire [W-1:0] mixed;", "  assign mixed = raw ^ W'(TAG+INDEX);",
             "  assign value = OP == 1 ? ~mixed : OP == 2 ? mixed ^ W'(3) : mixed;",
             "  assign width_code = W;", "endmodule",
             f"module cfg_leaf #(parameter int W = {b}, N = 2, MODE = 0, TAG = 10, ID = 0)();",
             "  logic [W-1:0] raw[0:N-1];", "  wire [W-1:0] value[0:N-1];",
             "  wire [31:0] width_code[0:N-1], branch_code[0:N-1];",
             "  for (genvar i = 0; i < N; i++) begin : g"]
    if form == "if":
        lines += ["    if (MODE == 0)", *["      "+x for x in route(0)],
                  "    else if (MODE == 1)", *["      "+x for x in route(1)],
                  "    else", *["      "+x for x in route(2)]]
    else:
        lines += ["    case (MODE)", "      0:", *["        "+x for x in route(0)],
                  "      1:", *["        "+x for x in route(1)],
                  "      default:", *["        "+x for x in route(2)], "    endcase"]
    lines += ["  end", "  initial begin", "    #(ID+1);", "    for (int phase = 0; phase < 13; phase++) begin",
              "      for (int lane = 0; lane < N; lane++)",
              "        for (int bitidx = 0; bitidx < W; bitidx++)",
              "          raw[lane][bitidx] = (((ID+1)*2048+(lane+1)*256+bitidx+1) >> phase) & 1;",
              "      #1;", '      $display("id=%0d p=%0d W=%0d N=%0d MODE=%0d TAG=%0d", ID, phase, W, N, MODE, TAG);',
              "      for (int lane = 0; lane < N; lane++)",
              '        $display("id=%0d p=%0d lane=%0d raw=%b value=%b branch=%0d bits=%0d,%0d",',
              "                 ID, phase, lane, raw[lane], value[lane], branch_code[lane],",
              "                 $bits(value[lane]), width_code[lane]);", "      #2;", "    end", "  end", "endmodule"]
    if hierarchy == "wrapped":
        lines += [f"module cfg_box #(parameter int PW = {b+5}, PM = {(int(mode)+2)%3})();",
                  *instance_lines(row), "endmodule"]
    lines += [f"module cfg_top #(parameter int PW = {b+5}, PM = {(int(mode)+2)%3})();"]
    lines += ["  cfg_box box();"] if hierarchy == "wrapped" else instance_lines(row)
    if prior in ("defparam", "both"):
        prefix = "box.target" if hierarchy == "wrapped" else "target"
        lines += [f"  defparam {prefix}.W = {b+2};", f"  defparam {prefix}.N = 1;",
                  f"  defparam {prefix}.MODE = 2;", f"  defparam {prefix}.TAG = 30;"]
    lines += ["  initial #100 $finish;", "endmodule", *config_lines(row)]
    return Case(
        case_name(row), "Configuration precedence and selective resets determine generated width, count and branch",
        "33.4.3 33.4.1.3 23.10.1 27.3 27.4 27.5",
        "A config targets a leaf through a direct or wrapped ordinary module "
        "hierarchy. Defaults, instance overrides and defparam provide distinct "
        "width/count/mode/tag values. Config set overrides W/MODE using a "
        "literal, a config localparam, or an ordinary parent parameter with "
        "distinct shadow values. W() resets only W; #() resets every parameter. "
        "The effective parameters determine packed widths, generated element "
        "count and if/case branch. An untargeted sibling retains its explicit "
        "parameters. Each leaf observes its own actual arrays, so a wrong "
        "count remains an output mismatch rather than a missing hierarchy "
        "compile error. Thirteen known frames identify per-instance bit "
        "positions through 135 bits even after inversion. Observer times are "
        "separated by the stable instance ID. Config RHS paths never traverse "
        "generate or instance-array scopes; no cell/library replacement or "
        "unknown parameter values are included.",
        "\n".join(lines), reference(row),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{key}={val}" for key, val in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
