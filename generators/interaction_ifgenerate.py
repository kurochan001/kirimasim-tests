"""Generated interface instances, selected branches and typed/modport bindings."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_ifgenerate"
VERSION = 1
CHAPTER = 27

MODEL = Model(
    "generated_interface_binding",
    (("base_width", ("1", "32", "33", "64", "65", "129")),
     ("count", ("1", "2", "3")), ("form", ("if", "case")),
     ("route", ("a", "b")), ("access", ("whole", "modport")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z"))),
    lambda row: True,
    groups=(("base_width", "state", "value"), ("count", "form", "route"),
            ("access", "form", "route"), ("count", "state", "value")),
    anchors=(("1", "1", "if", "a", "whole", "bit", "known"),
             ("129", "3", "case", "b", "modport", "logic", "z"),
             ("65", "2", "if", "b", "whole", "logic", "x"),
             ("33", "3", "case", "b", "modport", "bit", "z"),
             ("32", "2", "case", "b", "modport", "bit", "known"),
             ("64", "1", "if", "a", "whole", "logic", "known")),
    constraints=("864行はすべて合法で未対応による除外なし。generate要素iの幅は基底幅+i、最大131ビット。"
                 "各要素に同じ型のinterfaceを2個置き、選択した側だけwriter/readerへ接続し、他方を対照として駆動する。"
                 "if/caseの二つの選択肢には同じroute名を使う。b側は反転後にinterfaceのbit/logic型へ格納する。"
                 "13回の既知刺激で全要素・ビット位置・active/guardを識別し、X/Zには3回の追加刺激を与える。"
                 "virtual interface、interface配列ポート、clocking、modportの不正アクセスは対象外",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_ifgenerate_" + "_".join(row)


def word(width: int, lane: int, phase: int, guard: bool = False) -> str:
    if phase >= 11:
        return ("0" if guard or phase == 11 else "1") * width
    prefix = lane + (5 if guard else 1)
    return "".join(str((((prefix << 8) | (bit+1)) >> phase) & 1)
                   for bit in range(width-1, -1, -1))


def frames(row: Row) -> list[tuple[str, int, bool]]:
    result = [(f"k{phase}", phase, False) for phase in range(13)]
    if row[6] != "known":
        result += [(f"u{phase}", phase, True) for phase in range(3)]
    return result


def raw_word(row: Row, lane: int, phase: int, unknown: bool) -> str:
    width = int(row[0]) + lane
    bits = word(width, lane, phase)
    bad = {0, width-1, (lane+phase+1) % width}
    return "".join(row[6] if unknown and width-1-i in bad else bit for i, bit in enumerate(bits))


def stored(row: Row, raw: str) -> str:
    bits = raw.translate(str.maketrans("01xz", "10xx")) if row[3] == "b" else raw
    return bits.translate(str.maketrans("xz", "00")) if row[5] == "bit" else bits


def reference(row: Row) -> str:
    lines = []
    route = int(row[3] == "b")
    for label, phase, unknown in frames(row):
        for lane in range(int(row[1])):
            width = int(row[0]) + lane
            raw = raw_word(row, lane, phase, unknown)
            value, guard = stored(row, raw), word(width, lane, phase, True)
            active_id, guard_id = 11+lane+100*route, -1-lane
            a, aid, b, bid = ((value, active_id, guard, guard_id) if route == 0
                              else (guard, guard_id, value, active_id))
            lines += [f"{label} lane={lane} raw={raw}",
                      f"{label} lane={lane} a={a} atag={aid} b={b} btag={bid}",
                      f"{label} lane={lane} seen={value} sid={active_id} "
                      f"bits={width},{width},{width} branch={route}"]
    return "\n".join(lines) + "\n"


def branch(route: int) -> list[str]:
    active, guard = ("a", "b") if route == 0 else ("b", "a")
    return ["begin : route", f"  localparam int ACTIVE = {route};",
            f"  lane_writer #(.W(W), .ID({11+100*route}+i), .FLIP({route})) w(.raw(raw), .p({active}));",
            f"  lane_reader #(.W(W)) r(.p({active}), .seen(seen), .sid(sid));",
            f"  assign {guard}.payload = guard_data;", f"  assign {guard}.tag = -1-i;", "end"]


def make_case(row: Row) -> Case:
    base, count, form, route, access, state, value = row
    name = case_name(row)
    writer = "lane_if.writer" if access == "modport" else "lane_if"
    reader = "lane_if.reader" if access == "modport" else "lane_if"
    lines = ["`timescale 1ns/1ns", "interface lane_if #(parameter int W = 1);",
             f"  {state} [W-1:0] payload;", "  int tag;",
             "  modport writer(output payload, tag);", "  modport reader(input payload, tag);",
             "endinterface", "module lane_writer #(parameter int W = 1, ID = 0, FLIP = 0)(",
             f"  input logic [W-1:0] raw, {writer} p);",
             "  assign p.payload = FLIP ? ~raw : raw;", "  assign p.tag = ID;", "endmodule",
             "module lane_reader #(parameter int W = 1)(",
             f"  {reader} p, output wire [W-1:0] seen, output wire signed [31:0] sid);",
             "  assign seen = p.payload;", "  assign sid = p.tag;", "endmodule", f"module {name};",
             f"  localparam int BASE = {base}, N = {count};", f"  localparam bit SELECT = {int(route == 'b')};",
             "  for (genvar i = 0; i < N; i++) begin : g", "    localparam int W = BASE+i;",
             "    logic [W-1:0] raw, guard_data;", "    wire [W-1:0] seen;",
             "    wire signed [31:0] sid;", "    lane_if #(W) a(), b();"]
    if form == "if":
        lines += ["    if (SELECT == 0)", *["      " + line for line in branch(0)],
                  "    else", *["      " + line for line in branch(1)]]
    else:
        lines += ["    case (SELECT)", "      0:", *["        " + line for line in branch(0)],
                  "      1:", *["        " + line for line in branch(1)], "    endcase"]
    lines += ["  end", "  initial begin"]
    for label, phase, unknown in frames(row):
        for lane in range(int(count)):
            width = int(base)+lane
            lines += [f"    g[{lane}].raw = {literal(raw_word(row, lane, phase, unknown))};",
                      f"    g[{lane}].guard_data = {literal(word(width, lane, phase, True))};"]
        lines += ["    #1;"]
        for lane in range(int(count)):
            lines += [f'    $display("{label} lane={lane} raw=%b", g[{lane}].raw);',
                      f'    $display("{label} lane={lane} a=%b atag=%0d b=%b btag=%0d",',
                      f"             g[{lane}].a.payload, g[{lane}].a.tag, g[{lane}].b.payload, g[{lane}].b.tag);",
                      f'    $display("{label} lane={lane} seen=%b sid=%0d bits=%0d,%0d,%0d branch=%0d",',
                      f"             g[{lane}].seen, g[{lane}].sid, $bits(g[{lane}].a.payload),",
                      f"             $bits(g[{lane}].b.payload), $bits(g[{lane}].seen), g[{lane}].route.ACTIVE);"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Generated interface instances retain their widths, branch binding and independent state",
        "27.3 27.4 27.5 25.3 25.5 6.11.2 11.4.8",
        "Each generated element has two parameterized interfaces of width "
        "BASE+i. An if/case generate selects the a or b interface for typed "
        "whole-interface or modport writer/reader ports; the other interface "
        "is a driven guard. Both alternatives share the route scope name. "
        "Route b complements the four-state input before storing into the "
        "interface bit/logic payload. Unique per-element active and guard tags "
        "and all payloads are observed alongside the reader echo, actual "
        "widths and selected branch. Eleven known frames encode every bit "
        "position in each element up to 131 bits; two role frames distinguish "
        "active/guard histories even after complementing. X/Z cases keep "
        "those frames and add three unknown frames. All elements update before "
        "one time-step of settling and are observed independently. No virtual "
        "interfaces, interface-array ports, clocking or illegal modport access "
        "are included.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{key}={val}" for key, val in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
