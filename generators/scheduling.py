"""Generates tests of when a write to a variable becomes visible to the readers
of IEEE 1800-2023 4.4, for every combination the standard fixes.

Each test writes 22 to v, which starts at 11, in one of five ways: a blocking
assignment, a nonblocking one, a nonblocking one with an intra-assignment
delay of 1, a blocking write to the source of a continuous assignment to v,
and a force. It reads v in one of four ways: $display in the writing process
right after the write, $display in another process waiting for @(v), $strobe
right after the write, and $monitor. The write is in an initial or always
procedure, a task, a function, a fork branch, an interface or a generate
block, after no delay, #0 or #1.

The reference model follows the regions of 4.4.2: a blocking assignment
changes v at once (10.4.1); a nonblocking one in the NBA region of the same
time step (10.4.2), or one time step later with #1; a continuous assignment
and a force change v as update events of their own (10.3, 10.6.2); $strobe
and $monitor print at the end of the time step (21.2.2, 21.2.3); #0 resumes
in the Inactive region, after every process that started in the Active
region has reached its first wait (4.4.2.3).

Combinations whose result the standard leaves open are left out: reading v
in the writing process right after a continuous assignment or a force has to
change it, since 4.7 lets the simulator run the update before or after the
next statement, and waiting for @(v) in another process when v changes in the
Active region of time 0, since that process may not have started waiting
yet (4.7, 9.4.2). A function cannot contain a nonblocking assignment with a
delay, and the tests use only blocking writes in functions.
"""

import itertools

from common import Case

NAME = "scheduling"
VERSION = 1
CHAPTER = 4

OLD, NEW = 11, 22
WRITERS = {
    "blocking": ("v = 8'd22;", "a blocking assignment", "10.4.1"),
    "nba": ("v <= 8'd22;", "a nonblocking assignment", "10.4.2"),
    "nbadelay": ("v <= #1 8'd22;", "a nonblocking assignment with an intra-assignment delay "
                                   "of 1", "10.4.2 9.4.5"),
    "assign": ("src = 8'd22;", "a blocking write to src, which a continuous assignment "
                               "copies to v", "10.3.2"),
    "force": ("force v = 8'd22;", "a force", "10.6.2"),
}
READERS = {
    "same": ("$display in the writing process right after the write", "4.7"),
    "wait": ("another process that waits for @(v) and then displays v", "9.4.2"),
    "strobe": ("$strobe right after the write, which prints at the end of the time step",
               "21.2.2"),
    "monitor": ("$monitor, which prints at the end of every time step in which an argument "
                "changed", "21.2.3"),
}
CONTAINERS = {
    "initial": ("an initial procedure", "9.2.1"),
    "always": ("an always procedure", "9.2.2"),
    "task": ("a task called from an initial procedure", "13.3"),
    "function": ("a function called from an initial procedure", "13.4"),
    "fork": ("a branch of fork-join", "9.3.2"),
    "interface": ("an initial procedure of an interface instance", "25.3"),
    "generate": ("an initial procedure inside a generate block", "27.5"),
}
DELAYS = {"nodelay": ("", "at time 0 with no delay"), "delay0": ("#0", "after #0 at time 0"),
          "delay1": ("#1", "after #1")}


def allowed(w: str, r: str, c: str, d: str) -> bool:
    if r == "same" and w in ("assign", "force"):
        return False
    if r == "wait" and d == "nodelay" and w in ("blocking", "assign", "force"):
        return False
    if c == "function" and w != "blocking" and w != "assign":
        return False
    return True


def expected(w: str, r: str, d: str) -> list[str]:
    t = 1 if d == "delay1" else 0
    change = t + 1 if w == "nbadelay" else t
    if r == "same":
        return [f"t={t} A sees {NEW if w == 'blocking' else OLD}"]
    if r == "wait":
        return [f"t={change} B sees {NEW}"]
    if r == "strobe":
        return [f"t={t} strobe sees {OLD if w == 'nbadelay' else NEW}"]
    lines = [f"t=0 phase=1 v={NEW if change == 0 else OLD}"]
    if change:
        lines.append(f"t={change} phase=1 v={NEW}")
    return lines


def body(name: str, w: str, r: str, c: str, d: str) -> str:
    delay = DELAYS[d][0]
    write = WRITERS[w][0]
    after = []
    if r == "same":
        after.append('$display("t=%0t A sees %0d", $time, v);')
    if r == "strobe":
        after.append('$strobe("t=%0t strobe sees %0d", $time, v);')
    decl = (["logic [7:0] src = 8'd11;", "wire [7:0] v;", "assign v = src;"] if w == "assign"
            else ["logic [7:0] v = 8'd11;"])
    steps = ([f"{delay};"] if delay and c != "function" else []) + [write] + after

    def block(lines, indent):
        return [indent + l if l else l for l in lines]

    inner = []         # declarations and procedures where v lives
    outer = []         # the module's own items
    if c == "initial":
        inner += ["initial begin"] + block(steps, "  ") + ["end"]
    elif c == "always":
        inner += ["event never;", "always begin"] + block(steps, "  ") \
            + ["  @(never);", "end"]
    elif c == "task":
        inner += ["task automatic write_v();"] + block(steps, "  ") + ["endtask", "",
                                                                       "initial write_v();"]
    elif c == "function":
        inner += ["function automatic void write_v();"] + block(steps, "  ") \
            + ["endfunction", ""] + (["initial begin", f"  {delay};", "  write_v();", "end"]
                                     if delay else ["initial write_v();"])
    elif c == "fork":
        inner += ["initial fork", "  begin"] + block(steps, "    ") + ["  end", "join"]
    elif c == "generate":
        inner += ["if (1) begin : g", "  initial begin"] + block(steps, "    ") \
            + ["  end", "end"]
    else:
        inner += ["initial begin"] + block(steps, "  ") + ["end"]

    ref = "i.v" if c == "interface" else "v"
    readers = []
    if r == "wait":
        readers = [f'initial @({ref}) $display("t=%0t B sees %0d", $time, {ref});']
    if r == "monitor":
        readers = ["logic [7:0] phase = 8'd0;", "",
                   "initial begin",
                   f'  $monitor("t=%0t phase=%0d v=%0d", $time, phase, {ref});',
                   "  phase = 8'd1;", "end"]
    lines = ["`timescale 1ns/1ns", ""]
    if c == "interface":
        lines += [f"interface {name}_if;"] + block(decl + [""] + inner, "  ") + ["endinterface",
                                                                              ""]
        lines += [f"module {name};", f"  {name}_if i();"]
        lines += ([""] + block(readers, "  ") if readers else [])
    else:
        lines += [f"module {name};"] + block(decl, "  ")
        lines += ([""] + block(readers, "  ") if readers else [])
        lines += [""] + block(inner, "  ")
    lines += ["endmodule"]
    return "\n".join(lines)


def why(w: str, r: str, d: str) -> str:
    t = 1 if d == "delay1" else 0
    change = t + 1 if w == "nbadelay" else t
    when = {"blocking": "at once", "nba": f"in the NBA region of time {t}",
            "nbadelay": f"in the NBA region of time {change}",
            "assign": f"when the continuous assignment's update runs at time {t}",
            "force": f"when the force takes effect at time {t}"}[w]
    see = {"same": f"so the next statement sees {NEW if w == 'blocking' else OLD}",
           "wait": f"which wakes the waiting process at time {change}; it was already waiting"
                   + (" because #0 runs the write after it started" if d == "delay0" else
                      " because the change comes after the Active region of time 0"
                      if change == 0 else ""),
           "strobe": f"so $strobe at the end of time {t} sees "
                     f"{OLD if w == 'nbadelay' else NEW}",
           "monitor": "and $monitor prints once at the end of time 0, where phase changes, "
                      + ("with the new value" if change == 0 else
                         f"and again at time {change}")}[r]
    return f"v changes {when}, {see}."


def cases() -> list[Case]:
    out = []
    for w, r, c, d in itertools.product(WRITERS, READERS, CONTAINERS, DELAYS):
        if not allowed(w, r, c, d):
            continue
        name = f"test_gen_sched_{w}_{r}_{c}_{d}"
        writer, rd, cont, dl = WRITERS[w], READERS[r], CONTAINERS[c], DELAYS[d]
        comment = (f"IEEE 1800-2023 §4.4.2: v is written by {writer[1]} in {cont[0]} "
                   f"{dl[1]}, and read by {rd[0]}. {why(w, r, d)}")
        lrm = " ".join(dict.fromkeys(["4.4.2"] + writer[2].split() + rd[1].split()
                                     + cont[1].split() + (["4.4.2.3"] if d == "delay0" else [])))
        out.append(Case(name, f"A write by {writer[1]} in {cont[0]} {dl[1]} is seen by "
                              f"{rd[0]} as the regions of 4.4.2 order it",
                        lrm, comment, body(name, w, r, c, d),
                        "\n".join(expected(w, r, d)) + "\n"))
    return out
