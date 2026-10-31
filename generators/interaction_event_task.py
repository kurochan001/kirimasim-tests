"""Named-event task arguments, scoped sources and early/late one-shot listeners."""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_event_task"
VERSION = 1
CHAPTER = 15

MODEL = Model(
    "event_task_scope",
    (("home", ("module", "interface", "package")),
     ("passing", ("input", "ref")), ("emitter", ("direct", "task")),
     ("trigger", ("blocking", "nba")), ("listeners", ("1", "2", "3")),
     ("order", ("a_b", "b_a")), ("arrival", ("early", "late"))),
    lambda row: True,
    groups=(("home", "passing", "emitter"), ("passing", "trigger", "arrival"),
            ("listeners", "order", "arrival"), ("emitter", "trigger", "order"),
            ("home", "trigger", "arrival")),
    anchors=(("module", "input", "direct", "blocking", "1", "a_b", "early"),
             ("interface", "ref", "task", "nba", "3", "b_a", "late"),
             ("package", "input", "task", "blocking", "2", "a_b", "late"),
             ("module", "ref", "direct", "nba", "2", "b_a", "early"),
             ("interface", "input", "direct", "nba", "1", "a_b", "late"),
             ("package", "ref", "task", "blocking", "3", "b_a", "early")),
    constraints=("全288行は合法。静的寿命のイベントをautomatic taskのinput/refで渡す。"
                 "待機は@だけで、呼出し後1/6 tickで登録する。トリガと観測は別tickに置き、"
                 "複数待機者は別々の配列要素だけを更新する。静的stampへのNBAをトリガより先に予約し、"
                 "Active/NBAで起床した観測値を区別する。イベント変数の代入・比較・null待機、"
                 "triggered・wait_order・遅延付き非ブロッキングトリガ・virtual interface・"
                 "自動変数の寿命は対象外。input/refの再結合の差は検査しない。未対応による除外なし",),
)

SNAPSHOTS = ((0, "start"), (3, "noise"), (4, "pulse1"), (5, "pair1"),
             (9, "repeat1"), (11, "pair2"), (19, "rearmed"),
             (21, "round2_first"), (23, "round2_pair"), (26, "final"))


def case_name(row: Row) -> str:
    return "test_gen_cross_event_task_" + "_".join(row)


def reference(row: Row) -> str:
    """Closed-form wake times; no scheduler or simulator is used here."""
    n, order, late = int(row[4]), row[5].split("_"), row[6] == "late"
    records = {}
    for source in ("a", "b"):
        position = order.index(source)
        first = ((8, 10) if late else (3, 4))[position]
        first_token = ((30, 40) if late else (10, 20))[position]
        second = (22, 20)[position]
        second_token = (70, 60)[position]
        multiplier = 1 if source == "a" else 10
        extra = int(row[3] == "nba")
        records[source] = ((first, first_token * multiplier + extra),
                           (second, second_token * multiplier + extra))
    output = []
    for tick, label in SNAPSHOTS:
        output.append(f"{label} time={tick}")
        for source in ("a", "b"):
            # Driver snapshots precede any trigger at the same tick.
            completed = [(t, v) for t, v in records[source] if t < tick]
            for slot in range(3):
                active = completed if slot < n else []
                last_time, last_value = active[-1] if active else (-1, 0)
                output.append(f"{label} {source}{slot} hits={len(active)} "
                              f"at={last_time} value={last_value}")
    return "\n".join(output) + "\n"


def source(row: Row, who: str) -> str:
    if row[0] == "package":
        return "event_source::" + who
    return "bank_" + ("a" if who == "noise" else who) + (".noise" if who == "noise" else ".go")


def fire(row: Row, who: str) -> str:
    target = source(row, who)
    if row[2] == "direct":
        return ("-> " if row[3] == "blocking" else "->> ") + target + ";"
    owner = "event_source::" if row[0] == "package" else "bank_" + ("a" if who == "noise" else who) + "."
    return owner + "fire(" + target + ");"


def launch(row: Row) -> list[str]:
    return ["    fork", *[
        f"      listen_{who}.observe({source(row, who)}, {slot});"
        for who in ("a", "b") for slot in range(int(row[4]))], "    join_none"]


def snapshot(label: str) -> list[str]:
    result = [f'    $display("{label} time=%0d", $time);']
    for who in ("a", "b"):
        for slot in range(3):
            result += [f'    $display("{label} {who}{slot} hits=%0d at=%0d value=%0d",',
                       f"             listen_{who}.hits[{slot}], listen_{who}.at_tick[{slot}],",
                       f"             listen_{who}.captured[{slot}]);"]
    return result


def make_case(row: Row) -> Case:
    home, passing, emitter, trigger, listeners, order, arrival = row
    name, delay = case_name(row), 1 if arrival == "early" else 6
    op = "->" if trigger == "blocking" else "->>"
    lines = ["`timescale 1ns/1ns", f"{home} event_source;",
             "  event a, b, noise;" if home == "package" else "  event go, noise;"]
    if emitter == "task":
        lines += [f"  task automatic fire({passing} event ev);", f"    {op} ev;", "  endtask"]
    lines += [f"end{home}", "module event_listener;", "  int hits[3], at_tick[3], captured[3];",
              "  int stamp;", "  task automatic prepare(input int token);",
              "    stamp = token;", "    stamp <= token + 1;", "  endtask",
              f"  task automatic observe({passing} event ev, input int slot);",
              f"    #{delay};", "    @(ev);", "    hits[slot]++;",
              "    at_tick[slot] = $time;", "    captured[slot] = stamp;", "  endtask", "endmodule",
              f"module {name};"]
    if home != "package":
        lines += ["  event_source bank_a(), bank_b();"]
    lines += ["  event_listener listen_a(), listen_b();", "  initial begin"]
    for who in ("a", "b"):
        lines += [f"    listen_{who}.stamp = 0;"]
        for slot in range(3):
            lines += [f"    listen_{who}.hits[{slot}] = 0;",
                      f"    listen_{who}.at_tick[{slot}] = -1;",
                      f"    listen_{who}.captured[{slot}] = 0;"]
    a, b = order.split("_")
    pulses = {2: ("noise", 7), 3: (a, 10), 4: (b, 20), 8: (a, 30), 10: (b, 40),
              16: ("noise", 50), 20: (b, 60), 22: (a, 70), 24: ("a", 80), 25: ("b", 90)}
    observations = dict(SNAPSHOTS)
    now = 0
    for tick in sorted(set(pulses) | set(observations) | {0, 12}):
        if tick != now:
            lines += [f"    #{tick-now};"]
        now = tick
        if tick in observations:
            lines += snapshot(observations[tick])
        if tick in (0, 12):
            lines += launch(row)
        if tick in pulses:
            who, token = pulses[tick]
            lines += [f"    listen_a.prepare({token});", f"    listen_b.prepare({10*token});",
                      "    " + fire(row, who)]
    lines += ["    $finish;", "  end", "endmodule"]
    return Case(
        name, "Scoped named events keep task listeners separate and wake all armed listeners once",
        "15.5.2 15.5.1 13.5.1 13.5.2 25.3 26.2 9.3.2 4.4.2.2 4.4.2.4 10.4.2",
        "Two event sources in separate module/interface instances or one package "
        "are passed to automatic listener tasks by input/ref. Each source has "
        "one, two or three listeners writing separate slots; all three slots "
        "are observed. Early listeners arm before the first pulses. Late "
        "listeners arm after them and must wait for the later pulses, because "
        "@ does not remember past triggers. Direct triggers or scoped tasks "
        "use -> or ->>. Noise, repeated triggers after completion, and a second "
        "round with reversed source order distinguish identity, one-shot "
        "registration, fanout, time, payload and rearming. Static payload fields "
        "receive an NBA before each trigger: Active wakeups capture the old "
        "payload, while NBA event wakeups capture its queued successor. Only the producer "
        "prints, one tick after each relevant trigger; listener execution order "
        "does not affect output. Handles are never reassigned or compared, so "
        "this does not test the input/ref difference on rebinding, event "
        "reclamation, virtual interfaces or automatic source lifetimes.",
        "\n".join(lines), reference(row),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{k}={v}" for k, v in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
