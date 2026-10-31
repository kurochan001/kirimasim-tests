"""Clocking input sampling across state conversion, update region and access path.

IEEE 1800-2023 14.4/14.13 select the pre-edge value for #1step and
the Observed value for #0. Waiting on the clocking block (14.10), rather
than its raw clock edge, avoids racing the clockvar update.
"""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_clocking"
VERSION = 1
CHAPTER = 14

MODEL = Model(
    "clocking_input_sampling",
    (("width", ("1", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("access", ("local", "interface", "virtual")), ("skew", ("step", "zero")),
     ("edge", ("posedge", "negedge")), ("update", ("blocking", "nba"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("access", "skew", "edge"),
            ("access", "skew", "update"), ("state", "value", "skew")),
    anchors=(("1", "bit", "known", "local", "step", "posedge", "nba"),
             ("129", "logic", "z", "virtual", "zero", "negedge", "nba"),
             ("65", "logic", "x", "interface", "step", "posedge", "blocking"),
             ("33", "bit", "x", "virtual", "zero", "negedge", "blocking"),
             ("32", "logic", "known", "local", "zero", "negedge", "nba")),
    constraints=("全864行は合法。更新はmodule側のクロックエッジで行い、観測はcbイベントを待つ。"
                 "刺激の準備・初期値の設定・観測は別時刻。X/Z行にも既知値の対照を置く。"
                 "program由来のクロック、複数クロック、出力スキュー、inout、"
                 "iff、同一時刻内の複数エッジは対象外。未対応による除外はしない",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_clock_" + "_".join(row)


def phases(row: Row) -> list[tuple[str, str, str]]:
    """Before-edge and raw incoming bit strings, independent of sampling rules."""
    width = int(row[0])
    mask = (1 << width) - 1
    backgrounds = (int(("01" * width)[:width], 2), (1 << (width - 1)) | 1, 0)
    result = []
    for index, before in enumerate(backgrounds):
        old = f"{before:0{width}b}"
        raw = f"{mask ^ before:0{width}b}"
        result.append((f"p{index}_known", old, raw))
        if row[2] != "known":
            mixed = list(raw)
            for position in {0, width // 2, width - 1}:
                mixed[position] = row[2]
            result.append((f"p{index}_{row[2]}", old, "".join(mixed)))
    return result


def reference(row: Row) -> str:
    lines = []
    for count, (label, before, raw) in enumerate(phases(row), 1):
        live = raw.translate(str.maketrans("xz", "00")) if row[1] == "bit" else raw
        sampled = before if row[4] == "step" else live
        lines += [f"{label} before={before} source={raw}",
                  f"{label} hits={count} sampled={sampled} at_cb={live} live={live}"]
    return "\n".join(lines) + "\n"


def make_case(row: Row) -> Case:
    width, state, value, access, skew, edge, update = row
    w = int(width)
    name = case_name(row)
    inactive, active = ("0", "1") if edge == "posedge" else ("1", "0")
    delay = "1step" if skew == "step" else "0"
    site = name + "_bus"
    declarations = [f"  bit clk = 1'b{inactive};", f"  {state} [{w - 1}:0] data;",
                    f"  clocking cb @({edge} clk);", f"    input #{delay} data;", "  endclocking"]
    lines = ["`timescale 1ns/1ns"]
    if access == "local":
        lines += [f"module {name};", *declarations]
        storage, clock, cb = "data", "clk", "cb"
    else:
        lines += [f"interface {site};", *declarations, "  modport observer(clocking cb);",
                  "endinterface", f"module {name};", f"  {site} bus();"]
        storage, clock = "bus.data", "bus.clk"
        cb = "handle.cb" if access == "virtual" else "bus.cb"
        if access == "virtual":
            lines += [f"  virtual {site}.observer handle;"]
    lines += [f"  logic [{w - 1}:0] incoming, seen_sample, seen_live;",
              "  int hits = 0;", "  bit ready = 0;",
              f"  always @({edge} {clock}) {storage} {'<=' if update == 'nba' else '='} incoming;",
              "  initial begin"]
    if access == "virtual":
        lines.append("    handle = bus;")
    lines += ["    ready = 1;", "    forever begin", f"      @({cb});",
              f"      seen_sample = {cb}.data;", f"      seen_live = {storage};",
              "      hits++;", "    end", "  end", "  initial begin", "    wait (ready);"]
    for label, before, raw in phases(row):
        lines += [f"    {storage} = {literal(before)};", f"    incoming = {literal(raw)};", "    #2;",
                  f'    $display("{label} before=%b source=%b", {storage}, incoming);',
                  f"    {clock} = 1'b{active};", "    #1;",
                  f'    $display("{label} hits=%0d sampled=%b at_cb=%b live=%b",',
                  f"             hits, seen_sample, seen_live, {storage});",
                  f"    {clock} = 1'b{inactive};", "    #1;"]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Clocking inputs sample before or after typed blocking/NBA updates through three access paths",
        "14.13 14.4 14.10 4.4.2 10.4.1 10.4.2 6.11.2" +
        (" 25.5.5 25.9.1" if access != "local" else ""),
        "The inactive clock and before-edge data are prepared two ticks before each "
        "edge. A module writer updates data with blocking or NBA assignment. A separate "
        "observer waits on the clocking block event, after clockvars are updated: "
        "#1step retains the pre-edge value; #0 sees the Observed value. The observer "
        "records both the clockvar and live data, then the stimulus prints them one "
        "tick later along with a cumulative wake count and live storage. Local, "
        "interface and virtual-modport access use the same protocol. Three known "
        "backgrounds change every bit. X/Z rows add mixed unknowns at the endpoints "
        "and middle, plus the known controls; bit storage converts unknowns to zero "
        "before sampling. No raw-edge process reads the clockvar, and no data changes "
        "coincide with the delayed report. Output skew and multiple edges per time "
        "slot are outside this model.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
