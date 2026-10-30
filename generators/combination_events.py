"""Regression witnesses for event combinations tracked by issue 21.

These are small mechanism cases, not a t-way covering model. The expected
values follow event identity, event regions, lifetime and disable rules.
Existing event-trigger and named-fork tests remain reusable witnesses.
"""

import textwrap

from common import Case

NAME = "combination_events"
VERSION = 1
CHAPTER = 15


def make(name: str, description: str, clauses: str, comment: str, body: str,
         expected: list[str], *, chapter: int = 15) -> Case:
    return Case(name, description, clauses, comment, textwrap.dedent(body),
                "\n".join(expected) + "\n", chapter=chapter, extra={"issue": "21"})


def capture(structure: bool) -> Case:
    suffix = "struct" if structure else "scalar_control"
    name = "test_gen_combo_event_automatic_" + suffix + "_capture"
    declaration = ("  typedef struct { event go; int value; } item_t;\n"
                   if structure else "")
    local = "    item_t item;" if structure else "    event local_event;\n    int local_value;"
    event = "item.go" if structure else "local_event"
    value = "item.value" if structure else "local_value"
    body = f"""\
`timescale 1ns/1ns
module {name};
{declaration}  event first, second, third;
  int result[3], completed[3];
  task automatic launch(input int tag, output event retained);
{local}
    {value} = 10 + tag;
    retained = {event};
    fork
      begin
        @({event});
        result[tag] = {value};
        completed[tag] = completed[tag] + 1;
      end
    join_none
  endtask
  initial begin
    for (int i = 0; i < 3; i++) begin
      result[i] = 0;
      completed[i] = 0;
    end
    launch(0, first);
    launch(1, second);
    #1;
    $display("created=%0d distinct=%0d", first != null && second != null, first != second);
    $display("before=%0d,%0d", completed[0], completed[1]);
    -> first;
    #1;
    $display("first=%0d,%0d result=%0d,%0d", completed[0], completed[1], result[0], result[1]);
    first = null;
    -> second;
    #1;
    $display("second=%0d,%0d result=%0d,%0d", completed[0], completed[1], result[0], result[1]);
    second = null;
    launch(2, third);
    #1;
    $display("released=%0d,%0d new=%0d", first == null, second == null, third != null);
    -> third;
    #1;
    third = null;
    $display("final=%0d,%0d,%0d result=%0d,%0d,%0d null=%0d",
             completed[0], completed[1], completed[2], result[0], result[1], result[2],
             third == null);
    $finish;
  end
endmodule
"""
    return make(
        name, "Automatic event handles remain independent and survive a returned fork owner",
        "6.21 6.8 6.17 9.3.2 15.5.2 15.5.5.2" + (" 7.2.2" if structure else ""),
        "Each call creates a new event and spawns a waiter that reads the automatic "
        "event and payload after the task has returned. Separate delayed triggers "
        "identify the two calls and their captured frames. Clearing completed aliases "
        "with null does not disturb the remaining waiter; a third call gets its own "
        "event. The output establishes release of visible references, not physical GC "
        "memory reclamation. The scalar variant is a comparable positive control.",
        body,
        ["created=1 distinct=1", "before=0,0", "first=1,0 result=10,0",
         "second=1,1 result=10,11", "released=1,1 new=1",
         "final=1,1,1 result=10,11,12 null=1"], chapter=6,
    )


def initialized_event(conditional: bool) -> Case:
    kind = "conditional" if conditional else "return"
    name = "test_gen_combo_event_" + kind + "_initializer"
    function = ("""\
  function automatic bit choose(input bit flag);
    calls = calls + 1;
    return flag;
  endfunction
""" if conditional else """\
  function automatic event relay(input event original);
    calls = calls + 1;
    return original;
  endfunction
""")
    signature = ("input bit flag, input int tag" if conditional else
                 "input event original, input event other, input int tag")
    initializer = "choose(flag) ? first : second" if conditional else "relay(original)"
    compare = "flag" if conditional else "original == first"
    wrong = ("if (flag) -> second; else -> first;" if conditional else "-> other;")
    right = ("if (flag) -> first; else -> second;" if conditional else "-> original;")
    calls = ("check(0, 0);\n    check(1, 1);\n    check(0, 2);" if conditional else
             "check(first, second, 0);\n    check(second, first, 1);\n    check(first, second, 2);")
    body = f"""\
`timescale 1ns/1ns
module {name};
  event first, second;
  int calls, completed;
{function}  task automatic check({signature});
    event copied = {initializer};
    int observed = -1;
    $display("copy%0d first=%0d second=%0d calls=%0d chosen_first=%0d",
             tag, copied == first, copied == second, calls, {compare});
    fork
      begin
        @(copied);
        observed = $time;
        completed = completed + 1;
      end
      begin
        #1;
        {wrong}
        #1;
        {right}
      end
    join
    $display("wake%0d at=%0d completed=%0d", tag, observed, completed);
    copied = null;
    $display("clear%0d null=%0d originals_distinct=%0d", tag, copied == null, first != second);
  endtask
  initial begin
    calls = 0;
    completed = 0;
    {calls}
    $finish;
  end
  initial begin
    #40;
    $display("timeout");
    $finish;
  end
endmodule
"""
    expected = []
    choices = (0, 1, 0) if conditional else (1, 0, 1)
    for tag, first in enumerate(choices):
        expected += [f"copy{tag} first={first} second={1 - first} calls={tag + 1} chosen_first={first}",
                     f"wake{tag} at={2 * (tag + 1)} completed={tag + 1}",
                     f"clear{tag} null=1 originals_distinct=1"]
    return make(
        name, "Event-valued initialization preserves identity and evaluates its source once",
        "15.5.5.1 15.5.5.3 6.17 6.21 13.4 15.5.2" + (" 11.4.11" if conditional else ""),
        "An automatic event is initialized from a function return or from a known "
        "conditional expression on each task call. A side-effect counter detects "
        "duplicate evaluation. Both handle identities are displayed. Triggering the "
        "other event one tick before the selected one distinguishes the actual wait "
        "target; clearing the local alias leaves the original handles distinct. No "
        "unknown conditional or undefined null-event wait is used.", body, expected,
    )


def computed_always_ff() -> Case:
    name = "test_gen_combo_always_ff_computed_edge_capture"
    # Each item is a single source-bit change; data is stable before it.
    changes = (("a", 1, 0x11), ("b", 1, 0x22), ("a", 0, 0x33),
               ("b", 0, 0x44), ("b", 1, 0x55))
    body = ["`timescale 1ns/1ns", f"module {name};", "  bit a = 0, b = 0;",
            "  logic [7:0] data, sampled;",
            "  always_ff @(posedge (a ^ b)) sampled <= data;", "  initial begin"]
    expected = []
    a = b = 0
    sampled = None
    for i, (signal, new, data) in enumerate(changes, 1):
        old_expr = a ^ b
        if signal == "a":
            a = new
        else:
            b = new
        if old_expr == 0 and a ^ b == 1:
            sampled = data
        body += [f"    #{1 if i == 1 else 0} data = 8'h{data:02x};" if i == 1
                 else f"    data = 8'h{data:02x};", f"    {signal} = 1'b{new};", "    #1;",
                 f'    $display("step{i} expr=%b sampled=%h", a ^ b, sampled);']
        expected.append(f"step{i} expr={a ^ b} sampled={sampled:02x}")
    body += ["    data = 8'h66;", "    #1;",
             '    $display("held=%h", sampled);', "    $finish;", "  end", "endmodule"]
    expected.append(f"held={sampled:02x}")
    return make(
        name, "Always_ff captures only rising transitions of a computed edge expression",
        "9.2.2.4 9.4.2 10.4.2",
        "The only writer of sampled is one always_ff with one computed event control. "
        "Each input change is separated by a tick, and data is set before the change. "
        "The XOR rises three times and falls twice; observations one tick later check "
        "the NBA result and retention on falling edges and data-only changes.",
        "\n".join(body), expected, chapter=9,
    )


def writing_iff(accept: bool) -> Case:
    name = "test_gen_combo_iff_function_side_effect_" + ("accept" if accept else "reject")
    body = f"""\
`timescale 1ns/1ns
module {name};
  bit clk = 0, enable = 0;
  int calls = 0, accepted = 0, accepted_at = -1;
  logic [7:0] marker = 8'h5a;
  function automatic bit guard();
    calls = calls + 1;
    marker = marker ^ 8'hff;
    return enable;
  endfunction
  initial begin
    @(posedge clk iff guard());
    accepted = 1;
    accepted_at = $time;
  end
  initial begin
    #1 enable = 1;
    #1 enable = {int(accept)};
    #1;
    $display("before calls=%0d accepted=%0d marker=%h", calls, accepted, marker);
    clk = 1;
    #1;
    $display("edge calls=%0d accepted=%0d at=%0d marker=%h",
             calls, accepted, accepted_at, marker);
    enable = {int(not accept)};
    #1;
    $display("guard_only calls=%0d accepted=%0d marker=%h", calls, accepted, marker);
    $finish;
  end
endmodule
"""
    return make(
        name, "An iff function writes once on its source event and not on guard-only changes",
        "9.4.2.3 9.4.2 13.4",
        "A one-shot event control has exactly one rising clock transition after its "
        "wait has been armed. The guard increments a separate counter and toggles a "
        "marker; enable-only changes before and after the edge must not reevaluate "
        "it. The accepted and rejected variants observe both the guard side effect "
        "and whether the waiting process resumes. No non-edge transition is used to "
        "make assumptions about guard evaluation on filtered clock changes.",
        body, ["before calls=0 accepted=0 marker=5a",
               f"edge calls=1 accepted={int(accept)} at={3 if accept else -1} marker=a5",
               f"guard_only calls=1 accepted={int(accept)} marker=a5"], chapter=9,
    )


def trigger_after_issuer_end() -> Case:
    name = "test_gen_combo_event_control_trigger_after_issuer_end"
    return make(
        name, "An event-controlled nonblocking trigger remains scheduled after its issuer ends",
        "15.5.1 4.4.2.4 9.4.2",
        "The issuing initial process returns at time zero after scheduling a "
        "nonblocking named-event trigger for the next posedge. A separate waiter is "
        "armed before that edge. Values on both sides of the edge and the saved "
        "wake time detect a lost registration, an early trigger or a repeated wake. "
        "The target event and clock have static lifetime.",
        f"""\
`timescale 1ns/1ns
module {name};
  bit clk = 0;
  event done;
  int issued = 0, woke = 0, at_time = -1;
  initial begin
    ->> @(posedge clk) done;
    issued = 1;
  end
  initial begin
    @(done);
    woke = woke + 1;
    at_time = $time;
  end
  initial begin
    #1 $display("before issued=%0d woke=%0d", issued, woke);
    #1 clk = 1;
    #1 $display("after woke=%0d at=%0d", woke, at_time);
    clk = 0;
    #1 clk = 1;
    #1 $display("later woke=%0d at=%0d", woke, at_time);
    $finish;
  end
endmodule
""", ["before issued=1 woke=0", "after woke=1 at=2", "later woke=1 at=2"],
    )


def named_fork_wait_cleanup() -> Case:
    name = "test_gen_combo_named_fork_disable_waiters"
    return make(
        name, "Named disable ends a fork's delayed and event-waiting branches only",
        "9.6.2 9.3.2 9.3.4 15.5.2",
        "An unrelated process disables a named fork while one branch is delayed "
        "and another waits on a named event. Its join resumes at disable time. A "
        "later trigger must not wake the cancelled event branch, and the unrelated "
        "process still completes. No scheduled NBA from a disabled task is judged, "
        "because 9.6.2 does not specify that result.",
        f"""\
`timescale 1ns/1ns
module {name};
  event go;
  int delayed_done = 0, waiter_done = 0, unrelated_done = 0, joined_at = -1;
  initial begin
    fork : workers
      begin
        #7 delayed_done = 1;
      end
      begin
        @(go);
        waiter_done = 1;
      end
    join
    joined_at = $time;
  end
  initial #6 unrelated_done = 1;
  initial begin
    #2 disable workers;
    #1 -> go;
    #6;
    $display("delayed=%0d waiter=%0d unrelated=%0d joined_at=%0d",
             delayed_done, waiter_done, unrelated_done, joined_at);
    $finish;
  end
endmodule
""", ["delayed=0 waiter=0 unrelated=1 joined_at=2"], chapter=9,
    )


def cases() -> list[Case]:
    result = [capture(True), capture(False), initialized_event(False), initialized_event(True),
              computed_always_ff(), writing_iff(False), writing_iff(True),
              trigger_after_issuer_end(), named_fork_wait_cleanup()]
    for case, identifier in zip(result, ("E01", "E01", "E02", "E02", "E03",
                                         "E04", "E04", "E05", "E06"), strict=True):
        case.extra.update(issue="https://github.com/kurochan001/kirimasim-tests/issues/21",
                          combination_gap=identifier)
    return result
