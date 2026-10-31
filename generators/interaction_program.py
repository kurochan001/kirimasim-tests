"""Program completion, descendant cancellation and independent program lifetimes."""

from common import Case
from interaction_cover import Model, Row

NAME = "interaction_program"
VERSION = 1
CHAPTER = 24

MODEL = Model(
    "program_descendant_shutdown",
    (("finish", ("natural", "exit", "task")), ("initials", ("one", "two")),
     ("waiting", ("delay", "event", "level")), ("topology", ("flat", "nested")),
     ("progress", ("waiting", "partial")), ("spawn", ("none", "any")),
     ("keepers", ("one", "two"))),
    lambda row: True,
    groups=(("finish", "initials", "waiting"), ("spawn", "topology", "progress"),
            ("finish", "initials", "keepers")),
    anchors=(("natural", "one", "delay", "flat", "waiting", "none", "one"),
             ("natural", "two", "event", "nested", "partial", "any", "two"),
             ("exit", "two", "level", "nested", "partial", "none", "two"),
             ("task", "two", "delay", "flat", "partial", "any", "one")),
    constraints=("288行はすべて合法で未対応による除外なし。対象programの主initialは時刻4で終了または"
                 "$exitを呼び、追加initialは6で終わる。子の観測点は5、解放は7/8で、"
                 "自然終了の全initial待ちと明示終了を区別する。別programは12/15まで存続し、"
                 "moduleの20の番兵より先に暗黙の$finishが起きる。データ幅・状態型は因子に水増ししない",),
)


def case_name(row: Row) -> str:
    return "test_gen_cross_program_" + "_".join(row)


FIELDS = ("entered", "prepared", "short_done", "parent_done", "resumed", "primary_done",
          "secondary_done", "checkpoint", "escaped", "probe_escape", "task_returned",
          "caller_returned", "released", "survivor", "keeper_a", "keeper_b")


def reference(row: Row) -> str:
    finish, initials, waiting, topology, progress, spawn, keepers = row
    values = (1, int(progress == "partial"), 1, int(topology == "nested"),
              int(spawn == "any"), 1, int(finish == "natural" and initials == "two"),
              int(finish == "natural" and initials == "two"), 0, 0, 0, 0, 1, 1, 0, 0)

    def observe(label, time, a, b):
        updated = (*values[:-2], a, b)
        return f"{label} t={time} " + " ".join(f"{key}={value}" for key, value in zip(FIELDS, updated))

    lines = [observe("observe", 9, 0, 0)]
    if keepers == "two":
        lines += [observe("between", 13, 1, 0)]
    lines += [observe("final", 15 if keepers == "two" else 12, 1, int(keepers == "two"))]
    return "\n".join(lines) + "\n"


def display(label: str, indent: str = "    ") -> list[str]:
    lines = []
    for start in range(0, len(FIELDS), 3):
        keys = FIELDS[start:start+3]
        last = start + 3 >= len(FIELDS)
        fmt = (f"{label} t=%0d " if start == 0 else "")
        fmt += " ".join(f"{key}=%0d" for key in keys) + ("" if last else " ")
        args = (["$time"] if start == 0 else []) + list(keys)
        lines += [indent + ("$display" if last else "$write") + f'("{fmt}",',
                  indent + "       " + ", ".join(args) + ");"]
    return lines


def make_case(row: Row) -> Case:
    finish, initials, waiting, topology, progress, spawn, keepers = row
    name = case_name(row)
    wait = {"delay": "#7;", "event": "@release_event;", "level": "wait (released);"}[waiting]
    worker = ["begin", "  entered++;", *(["  #1 prepared++;"] if progress == "partial" else []),
              "  " + wait, "  escaped++;", "end"]
    probe = ["begin", "  #5 checkpoint++;", "  #2 probe_escape++;", "end"]
    descendants = worker + probe
    if topology == "nested":
        descendants = ["begin", "  fork", *["    " + line for line in descendants],
                       "  join_none", "  #2 parent_done++;", "end"]
    lines = ["`timescale 1ns/1ns", f"module {name};",
             *["  int " + ", ".join(f"{key} = 0" for key in FIELDS[i:i+4]) + ";"
               for i in range(0, len(FIELDS), 4)], "  event release_event;", "  program target;"]
    if finish == "task":
        lines += ["    task automatic stop_now();", "      $exit;", "      task_returned++;", "    endtask"]
    lines += ["    initial begin", "      fork",
             *["        " + line for line in descendants], "        #1 short_done++;",
             "      join_" + spawn, "      resumed = $time;",
             "      #" + ("3" if spawn == "any" else "4") + ";", "      primary_done = 1;"]
    if finish == "exit":
        lines += ["      $exit;", "      caller_returned++;"]
    elif finish == "task":
        lines += ["      stop_now();", "      caller_returned++;"]
    lines += ["    end"]
    if initials == "two":
        lines += ["    initial #6 secondary_done++;"]
    lines += ["  endprogram", "  program keeper_first;", "    initial begin", "      " + wait,
              "      survivor = 1;", "    end", "    initial #12 keeper_a = 1;", "  endprogram"]
    if keepers == "two":
        lines += ["  program keeper_second;", "    initial #15 keeper_b = 1;", "  endprogram"]
    lines += ["  initial begin", "    #8 released = 1;", "    -> release_event;", "  end",
              "  initial begin", "    #9;", *display("observe")]
    if keepers == "two":
        lines += ["    #4;", *display("between")]
    lines += ["  end", '  initial #20 $display("module sentinel survived");',
              "  final begin", *display("final"), "  end", "endmodule"]
    return Case(
        name, "Program completion cancels its descendants while other programs remain alive",
        "24.3 24.7 9.3.2 9.2.3 9.4.2 9.4.3 15.5",
        "A nested portless program forks a waiting worker, a time-5 checkpoint "
        "and a time-1 short child. join_none or join_any resumes at time 0 or 1; "
        "the primary initial ends or calls $exit at 4, directly or through an "
        "automatic task. An optional second initial ends at 6. Only natural "
        "completion with two initials keeps the checkpoint alive at 5. Workers "
        "wait on delay/event/level conditions and optionally make progress "
        "before waiting. A nested fork makes the worker and checkpoint "
        "grandchildren whose intermediate parent ends at 2. All descendants "
        "must be cancelled before their late writes at 7/8. A live counterpart "
        "in an independent keeper uses the same wait and must wake normally. "
        "Keeper programs last until 12/15, keeping observation at 9 and optionally 13 "
        "alive. A single module final observes the implicit global finish; "
        "no explicit $finish or disable masks program cancellation. All times "
        "are separated to avoid process-order races.",
        "\n".join(lines), reference(row),
        extra={"interaction_model": f"{MODEL.name}@{MODEL.version}",
               "interaction_values": " ".join(f"{key}={val}" for key, val in MODEL.values(row).items())},
    )


def cases() -> list[Case]:
    return [make_case(row) for row in MODEL.select()]
