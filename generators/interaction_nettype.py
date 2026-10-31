"""Default net types, implicit port declarations and lexical directive reset."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_nettype"
VERSION = 1
CHAPTER = 22

MODEL = Model(
    "implicit_port_nettype",
    (("nettype", ("wire", "tri", "wand", "triand", "wor", "trior")),
     ("width", ("1", "32", "33", "64", "65", "129")),
     ("style", ("nonansi", "ansi")), ("override", ("implicit", "wire")),
     ("value", ("binary", "xz")), ("reset", ("wire", "resetall"))),
    lambda row: True,
    groups=(("nettype", "style", "override"), ("nettype", "value", "reset"),
            ("width", "style", "override")),
    anchors=(("wire", "1", "nonansi", "implicit", "binary", "wire"),
             ("wand", "129", "nonansi", "implicit", "xz", "resetall"),
             ("wor", "65", "ansi", "wire", "xz", "wire"),
             ("triand", "33", "ansi", "implicit", "binary", "resetall"),
             ("trior", "64", "nonansi", "wire", "xz", "resetall"),
             ("tri", "32", "ansi", "implicit", "xz", "wire")),
    constraints=("576行はすべて合法で未対応による除外なし。等強度の2ドライバでwire/tri、"
                 "wand/triand、wor/triorを検査する。各別名は指示の字句と宣言規則の検査のため保持する。"
                 "暗黙のscalar出力を対照にし、vector出力だけを明示wireで上書きできる。"
                 "後続moduleはdefault_nettype wireまたはresetall後に定義する。"
                 "none/uwireの不正な多重駆動、tri0/tri1のpull、triregの電荷保持、強度差・遅延は対象外。"
                 "binary刺激にもwireの競合によるXがあるため全件fourstate=yes",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_nettype_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, str]]:
    levels = "01" if row[4] == "binary" else "01xz"
    n, w = len(levels), int(row[1])
    truth = [("".join(levels[(phase + bit) % n] for bit in range(w-1, -1, -1)),
              "".join(levels[(phase // n + bit // n) % n] for bit in range(w-1, -1, -1)))
             for phase in range(n*n)]
    # Eight identical-driver frames identify positions 1..129 independently
    # of the resolution rule and expose copying a lower word into an upper one.
    tags = ["".join(str(((bit + 1) >> phase) & 1) for bit in range(w-1, -1, -1))
            for phase in range(8)]
    return truth + [(bits, bits) for bits in tags]


def resolve(kind: str, a: str, b: str) -> str:
    if a == "z":
        return b
    if b == "z":
        return a
    if kind in ("wand", "triand"):
        return "0" if "0" in (a, b) else "1" if a == b == "1" else "x"
    if kind in ("wor", "trior"):
        return "1" if "1" in (a, b) else "0" if a == b == "0" else "x"
    return a if a == b else "x"


def reference(row: Row) -> str:
    kind, width, style, override, value, reset = row
    w, lines = int(width), []
    for phase, (a, b) in enumerate(phases(row)):
        y = "".join(resolve("wire" if override == "wire" else kind, x, z) for x, z in zip(a, b))
        g = resolve(kind, a[-1], b[-1])
        after = "".join(resolve("wire", x, z) for x, z in zip(a, b))
        lines += [f"p{phase} input a={a} b={b}", f"p{phase} y={y} inside={y} g={g} ig={g}",
                  f"p{phase} reset={after} inside={after} pg={after[-1]} ipg={after[-1]}",
                  f"p{phase} bits={w},{w},{w},1,{w},1"]
    return "\n".join(lines) + "\n"


def declaration(name: str, width: int, style: str, override: str) -> list[str]:
    kind = "wire " if override == "wire" else ""
    if style == "nonansi":
        lines = [f"module {name}(a, b, y, g);", f"  input [{width-1}:0] a, b;",
                 f"  output {kind}[{width-1}:0] y;", "  output g;"]
    else:
        lines = [f"module {name}(", f"  input [{width-1}:0] a, b,",
                 f"  output {kind}[{width-1}:0] y,", "  output g);"]
    return lines + ["  assign y = a;", "  assign y = b;",
                    "  assign g = a[0];", "  assign g = b[0];", "endmodule"]


def make_case(row: Row) -> Case:
    kind, width, style, override, value, reset = row
    w, name = int(width), case_name(row)
    # Short helper names avoid long generated declaration lines; they are local
    # to each standalone test, whose source is compiled in a private directory.
    lines = ["`timescale 1ns/1ns", f"`default_nettype {kind}",
             *declaration("selected_port", w, style, override),
             "`resetall" if reset == "resetall" else "`default_nettype wire",
             "`timescale 1ns/1ns", *declaration("reset_port", w, style, "implicit"),
             f"module {name};", f"  logic [{w-1}:0] a, b;",
             f"  wire [{w-1}:0] y, post;", "  wire g, post_g;",
             "  selected_port c(a, b, y, g);", "  reset_port r(a, b, post, post_g);", "  initial begin"]
    for phase, (a, b) in enumerate(phases(row)):
        lines += [f"    a = {literal(a)};", f"    b = {literal(b)};", "    #1;",
                  f'    $display("p{phase} input a=%b b=%b", a, b);',
                  f'    $display("p{phase} y=%b inside=%b g=%b ig=%b", y, c.y, g, c.g);',
                  f'    $display("p{phase} reset=%b inside=%b pg=%b ipg=%b", post, r.y, post_g, r.g);',
                  f'    $display("p{phase} bits=%0d,%0d,%0d,%0d,%0d,%0d",',
                  "             $bits(c.a), $bits(c.b), $bits(c.y), $bits(c.g), $bits(r.y), $bits(r.g));"]
    lines += ["    $finish;", "  end", "endmodule", "`default_nettype wire"]
    return Case(
        name, "Default net type determines implicit port resolution until a lexical directive reset",
        "22.8 22.3 6.10 6.6.1 6.6.3 23.2.2.1 23.2.2.3",
        "A selected module is declared under wire/tri/wand/triand/wor/trior, "
        "using ANSI or non-ANSI ports. Its vector output is implicit or "
        "explicit wire; a scalar output remains implicit as a default-type "
        "control. Two equal-strength continuous drivers expose resolution. "
        "After default_nettype wire or resetall, a second module is declared "
        "with implicit ports. Both modules receive the same stimulus; the "
        "later module must use wire independently of the earlier declaration. "
        "Each bit sees all four binary driver pairs or all sixteen four-state "
        "pairs over time. Eight equal-driver frames encode each bit position "
        "independently of the net kind and detect upper/lower word reuse. "
        "Parent and child resolved values and implicit port "
        "widths are observed after a full time step. Binary stimulus still "
        "creates X through conflicting wire drivers, so every case depends "
        "on four-state behavior. No pull defaults, charge storage, unequal "
        "strengths, delays, or invalid none/uwire multidriver designs are included.",
        "\n".join(lines), reference(row), fourstate=True,
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{key}={val}" for key, val in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
