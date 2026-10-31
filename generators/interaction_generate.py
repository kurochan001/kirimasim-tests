"""Generate hierarchy, wildcard package lookup and local type/constant shadowing."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_generate"
VERSION = 1
CHAPTER = 27

MODEL = Model(
    "generate_scope_lookup",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("access", ("import", "qualified")), ("shadow", ("none", "local")),
     ("depth", ("one", "two")), ("branch", ("if", "case"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("access", "shadow", "depth"),
            ("access", "shadow", "branch"), ("access", "depth", "branch"),
            ("state", "shadow", "access")),
    anchors=(("1", "bit", "known", "import", "none", "one", "if"),
             ("129", "logic", "z", "import", "local", "two", "case"),
             ("65", "logic", "x", "qualified", "local", "two", "if"),
             ("33", "bit", "x", "import", "local", "one", "case"),
             ("32", "logic", "known", "qualified", "none", "one", "case"),
             ("64", "logic", "known", "import", "local", "two", "if")),
    constraints=("全576行は合法。ワイルドカードimportと局所宣言の隠蔽を使い、"
                 "衝突して不正になる明示importは使わない。"
                 "2インスタンスのSELECTを0/1とし、それぞれ2個の生成要素を作る。"
                 "分岐0だけが局所WIDTH/ORIGIN/word_tを宣言し、幅を1増やし状態型を逆にする。"
                 "明示修飾は局所宣言があってもpackageの型・定数を使う。未対応による除外なし。"
                 "動的な階層添字・config・defparam・無名generate・符号付き演算は対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_generate_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, str, str]]:
    size = int(row[0]) + 1
    p = ("0" * size, "1" * size, ("10" * size)[:size])
    result = [(f"k{i}", p[i], p[(i+1) % 3]) for i in range(3)]
    if row[2] != "known":
        for i in range(3):
            values = []
            for bits in (p[i], p[(i+1) % 3]):
                chars = list(bits)
                for index in {0, size // 2, size - 1}:
                    chars[index] = row[2]
                values.append("".join(chars))
            result.append((f"u{i}", *values))
    return result


def leaf(row: Row, select: int, lane: int) -> dict:
    kind = (select + lane) % 2
    local = row[4] == "local" and kind == 0
    used = local and row[3] == "import"
    width = int(row[0]) + int(used)
    state = ("logic" if row[1] == "bit" else "bit") if used else row[1]
    return dict(kind=kind, local=int(local), index=lane, width=width,
                bits=width, origin=9 if used else 5, state=state)


def value(row: Row, raw: str, select: int, lane: int) -> str:
    info = leaf(row, select, lane)
    width = info["width"]
    mask = f"{(info['origin']+lane) & ((1 << width)-1):0{width}b}"
    result = "".join(str(int(x) ^ int(y)) if x in "01" else "x"
                     for x, y in zip(raw[-width:], mask))
    return result.replace("x", "0") if info["state"] == "bit" else result


def reference(row: Row) -> str:
    lines = []
    for label, a, b in phases(row):
        for owner, raw, select in (("a", a, 0), ("b", b, 1)):
            lines.append(f"{label} {owner} source={raw}")
            for lane in range(2):
                info = leaf(row, select, lane)
                fields = " ".join(f"{key}={info[key]}" for key in
                                  ("kind", "local", "index", "width", "bits", "origin"))
                lines.append(f"{label} {owner} lane={lane} {fields} value={value(row, raw, select, lane)}")
    return "\n".join(lines) + "\n"


def path(row: Row, owner: str, lane: int) -> str:
    return f"{owner}.lanes[{lane}]." + ("layer." if row[5] == "two" else "") + "choice"


def declarations(row: Row, kind: int) -> list[str]:
    access, shadow = row[3:5]
    local = shadow == "local" and kind == 0
    lines = []
    if local:
        opposite = "logic" if row[1] == "bit" else "bit"
        lines += ["      localparam int WIDTH = scope_pkg::WIDTH + 1;",
                  "      localparam int ORIGIN = 9;", f"      typedef {opposite} [WIDTH-1:0] word_t;"]
    prefix = "scope_pkg::" if access == "qualified" else ""
    lines += [f"      typedef {prefix}word_t used_t;", f"      localparam int KIND = {kind};",
              f"      localparam int LOCAL = {int(local)};", "      localparam int INDEX = g;",
              f"      localparam int USED_WIDTH = {prefix}WIDTH;",
              f"      localparam int USED_ORIGIN = {prefix}ORIGIN;", "      localparam int TYPE_BITS = $bits(used_t);",
              "      used_t value;", "      assign value = source ^ used_t'(USED_ORIGIN + INDEX);"]
    return lines


def make_case(row: Row) -> Case:
    width, state, raw_value, access, shadow, depth, branch = row
    w, name = int(width), case_name(row)
    lines = ["`timescale 1ns/1ns", "package scope_pkg;", f"  localparam int WIDTH = {w};",
             "  localparam int ORIGIN = 5;", f"  typedef {state} [WIDTH-1:0] word_t;", "endpackage",
             "module scope_worker #(parameter bit SELECT = 0);"]
    if access == "import":
        lines.append("  import scope_pkg::*;")
    lines += [f"  logic [{w}:0] source;", "  for (genvar g = 0; g < 2; g++) begin : lanes"]
    if depth == "two":
        lines.append("    if (1) begin : layer")
    condition = "((SELECT + g) % 2)"
    if branch == "if":
        lines += [f"    if ({condition} == 0) begin : choice", *declarations(row, 0),
                  "    end else begin : choice", *declarations(row, 1), "    end"]
    else:
        lines += [f"    case ({condition})", "      0: begin : choice", *declarations(row, 0),
                  "      end", "      default: begin : choice", *declarations(row, 1), "      end", "    endcase"]
    if depth == "two":
        lines.append("    end")
    lines += ["  end", "endmodule", f"module {name};", "  scope_worker #(.SELECT(0)) a();",
              "  scope_worker #(.SELECT(1)) b();", "  initial begin"]
    for label, a, b in phases(row):
        lines += [f"    a.source = {literal(a)};", f"    b.source = {literal(b)};", "    #1;"]
        for owner in ("a", "b"):
            lines += [f'    $display("{label} {owner} source=%b", {owner}.source);']
            for lane in range(2):
                p = path(row, owner, lane)
                lines += [f'    $write("{label} {owner} lane={lane} kind=%0d local=%0d index=%0d",',
                          f"           {p}.KIND,", f"           {p}.LOCAL,", f"           {p}.INDEX);",
                          '    $write(" width=%0d bits=%0d origin=%0d",',
                          f"           {p}.USED_WIDTH,", f"           {p}.TYPE_BITS,",
                          f"           {p}.USED_ORIGIN);",
                          f'    $display(" value=%b", {p}.value);']
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Generate branches resolve package types and constants or local shadows in independent scopes",
        "27.4 27.5 26.3 26.4 23.6 23.8 6.18 6.11.2 10.3.2",
        "Two parameterized workers each generate two named cells with opposite "
        "branch selections. If/case alternatives share a legal conditional block "
        "name. Optional extra nesting changes the hierarchical path. Branch zero "
        "can declare WIDTH, ORIGIN and word_t locally, with width increased by one "
        "and the opposite bit/logic state type. Unqualified wildcard-import lookup "
        "then selects that local declaration; explicit package qualification "
        "continues to select the package declaration. Each cell continuously "
        "assigns its selected type from the enclosing instance source XOR a "
        "genvar-dependent constant. Hierarchical observations report branch, "
        "shadow presence, implicit genvar localparam, selected width, type bits, "
        "constant and value after settling. Known phases and mixed X/Z phases "
        "distinguish truncation and conversion after XOR. No config, defparam, "
        "unnamed blocks, dynamic hierarchy indices or signed arithmetic is used.",
        "\n".join(lines), reference(row), fourstate=raw_value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
