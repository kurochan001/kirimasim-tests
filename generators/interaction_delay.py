"""Continuous-assignment delay choice, inertial cancellation and typed sources."""

from common import Case
from interaction_cond import literal
from interaction_cover import Model, Row

NAME = "interaction_delay"
VERSION = 1
CHAPTER = 10

MODEL = Model(
    "continuous_delay_inertial",
    (("width", ("1", "2", "32", "33", "64", "65", "129")),
     ("state", ("bit", "logic")), ("value", ("known", "x", "z")),
     ("profile", ("one", "two", "three")), ("pulse", ("short", "long")),
     ("expression", ("direct", "invert"))),
    lambda row: True,
    groups=(("width", "state", "value"), ("width", "value", "profile"),
            ("profile", "pulse", "expression"), ("state", "value", "expression")),
    anchors=(("1", "logic", "x", "three", "short", "direct"),
             ("2", "logic", "z", "three", "long", "direct"),
             ("129", "logic", "z", "two", "short", "invert"),
             ("65", "bit", "x", "three", "long", "direct"),
             ("33", "logic", "known", "one", "short", "invert"),
             ("32", "bit", "known", "two", "long", "direct"),
             ("64", "logic", "x", "two", "short", "direct")),
    constraints=("全504行は合法。幅1はスカラnet、幅2以上はベクタnetを使う。"
                 "1ビットpacked vectorは対象外。遅延は5、(7,3)、(7,5,2)で、"
                 "パルス幅1/10は遅延と一致しない。20 tickの初期整定後、Postponedで毎tick観測する。"
                 "短パルスの復帰と既知値の再予約は、予約済み更新より前に実行する。"
                 "net宣言の遅延・複数ドライバ・強度・SDF・min/typ/max・未知値の遅延は対象外。"
                 "未対応による除外なし",),
)

PROFILES = {"one": (5, 5, 5), "two": (7, 3, 3), "three": (7, 5, 2)}
DELAY_TEXT = {"one": "5", "two": "7, 3", "three": "7, 5, 2"}


def case_name(row: Row) -> str:
    return "test_gen_cross_delay_" + "_".join(row)


def stimulus(row: Row) -> tuple[list[tuple[int, str]], int]:
    width = int(row[0])
    zero, one = "0" * width, "1" * width
    alternate = ("10" * width)[:width]
    opposite = alternate.translate(str.maketrans("01", "10"))
    events = [(0, zero)]
    tick = 2
    for bits in (one, zero, alternate, opposite, zero):
        events.append((tick, bits))
        tick += 12
    duration = 1 if row[4] == "short" else 10
    events += [(tick, one), (tick + duration, zero)]
    tick += duration + 12
    # Replace a pending known value before it can arrive, then let the new
    # request settle. Width 1 also supplies cancellation back to the old value.
    events += [(tick, one), (tick + 1, opposite), (tick + 13, zero)]
    tick += 25
    if row[2] != "known":
        unknown = row[2] * width
        mixed = list(alternate)
        for index in {0, width // 2, width - 1}:
            mixed[index] = row[2]
        for bits in (unknown, zero, "".join(mixed), zero):
            events.append((tick, bits))
            tick += 12
        events += [(tick, unknown), (tick + duration, zero)]
        tick += duration + 12
    return events, tick + 2


def typed(row: Row, raw: str) -> str:
    return raw.translate(str.maketrans("xz", "00")) if row[1] == "bit" else raw


def expression(row: Row, source: str) -> str:
    return source if row[5] == "direct" else source.translate(str.maketrans("01xz", "10xx"))


def propagation(row: Row, new: str) -> int:
    rise, fall, off = PROFILES[row[3]]
    if row[0] == "1":
        return {"0": fall, "1": rise, "z": off, "x": min(rise, fall, off)}[new]
    return fall if set(new) == {"0"} else off if set(new) == {"z"} else rise


def reference(row: Row) -> str:
    events, end = stimulus(row)
    drives = dict(events)
    raw = "0" * int(row[0])
    source = typed(row, raw)
    rhs = output = expression(row, source)
    pending = None
    changes, last = 0, -1
    result = []
    for tick in range(end + 1):
        if pending is not None and pending[0] == tick:
            output = pending[1]
            changes += 1
            last = tick
            pending = None
        if tick in drives:
            raw = drives[tick]
            source = typed(row, raw)
            new = expression(row, source)
            if new != rhs:
                rhs = new
                # A request for the already scheduled value keeps its deadline.
                if pending is None or pending[1] != new:
                    pending = None
                    if new != output:
                        pending = (tick + propagation(row, new), new)
        result.append(f"tick={tick} raw={raw} source={source} rhs={rhs} "
                      f"out={output} changes={changes} last={last}")
    return "\n".join(result) + "\n"


def make_case(row: Row) -> Case:
    width, state, value, profile, pulse, operation = row
    w, name = int(width), case_name(row)
    events, end = stimulus(row)
    net = "wire delayed;" if w == 1 else f"wire [{w-1}:0] delayed;"
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  logic [{w-1}:0] raw;", f"  {state} [{w-1}:0] source;",
             f"  wire [{w-1}:0] rhs;", "  " + net, "  int tick, changes, last;",
             "  assign rhs = " + ("source;" if operation == "direct" else "~source;"),
             f"  assign #({DELAY_TEXT[profile]}) delayed = rhs;",
             "  always @(delayed) begin", "    if ($time >= 20) begin",
             "      changes++;", "      last = $time - 20;", "    end", "  end",
             "  initial begin", "    raw = '0; source = '0;",
             "    tick = 0; changes = 0; last = -1;", "    #20;", "    fork", "      begin"]
    now = 0
    for at, raw in events:
        if at != now:
            lines += [f"        #{at-now};"]
        lines += [f"        raw = {literal(raw)};", "        source = raw;"]
        now = at
    lines += ["      end", "      begin", f"        repeat ({end+1}) begin",
              '          $strobe("tick=%0d raw=%b source=%b rhs=%b out=%b changes=%0d last=%0d",',
              "                  tick, raw, source, rhs, delayed, changes, last);",
              "          #1; tick++;", "        end", "      end", "    join",
              "    $finish;", "  end", "endmodule"]
    return Case(
        name, "Continuous delays preserve scalar/vector choices, typed sources and inertial cancellation",
        "10.3.3 28.16 6.11.2 7.4.1 21.2.2 4.4.2.9",
        "A single delayed continuous driver uses one, two or three delays. "
        "Width 1 declares a scalar net; other widths declare vectors. Scalar "
        "X propagation uses the minimum delay, while vector changes use fall "
        "for zero, turn-off for all-Z and rise otherwise. Typed bit/logic "
        "sources are filled before optional bitwise inversion. Known steps "
        "accompany all X/Z cases. Pulses last one or ten ticks, strictly away "
        "from the propagation delays; another known request replaces a "
        "pending value. Twenty warmup ticks are excluded. Postponed snapshots "
        "sample every later tick, with output change count and last-change "
        "time detecting transient extra events. No source change coincides "
        "with a pending output update. A single driver, constant integral "
        "delays and 1ns precision avoid resolution, rounding and equal-time "
        "input/output races. Net declaration delays, strength, SDF, multiple "
        "drivers and one-bit packed-vector classification are outside scope.",
        "\n".join(lines), reference(row), fourstate=value != "known",
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
