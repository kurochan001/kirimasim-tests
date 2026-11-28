# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""String methods and indexed updates through task formals."""

from itertools import product

from common import Case

NAME = "string_argument_updates"
VERSION = 1
CHAPTER = 13

LOCATIONS = {
    "scalar": ("  string stored, neighbor;", "stored", "neighbor", ()),
    "fixed": ("  string stored[-1:1];", "stored[slot]", "stored[1]", ("    slot = -1;",)),
    "dynamic": ("  string stored[];", "stored[slot]", "stored[1]",
                ("    stored = new[3];", "    slot = 2;")),
}
UPDATES = {
    "putc": ('value.putc(1, "X");', lambda text: text[:1] + "X" + text[2:]),
    "indexed": ('value[2] = "Y";', lambda text: text[:2] + "Y" + text[3:]),
    "zero": ("value.putc(1, 16'h0100);", lambda text: text),
    "substring": ('value = {value.substr(1, 2), "Q"};', lambda text: text[1:3] + "Q"),
}


def make_case(direction, location, update):
    declaration, target, guard, setup = LOCATIONS[location]
    statement, change = UPDATES[update]
    initial, seed = "Start", "Task" if direction == "output" else "Start"
    updated = change(seed)
    caller_mid = updated if direction == "ref" else initial
    caller_final = initial if direction == "input" else updated + "!"
    prepare = '    value = "Task";\n' if direction == "output" else ""
    slot_decl = "  int slot;\n" if setup else ""
    setup = "".join(line + "\n" for line in setup)
    name = f"test_gen_string_arg_{direction}_{location}_{update}"
    expected = [
        f"before=[{seed}] actual=[{initial}]",
        f"mid=[{updated}] actual=[{caller_mid}] byte={ord(updated[1]):02x}",
        f"after=[{caller_final}] saved=[{initial}] guard=[Keep]",
    ]
    body = f"""module {name};
{declaration}
{slot_decl}  string saved;

  task automatic modify({direction} string value);
    byte readback;
{prepare}    $display("before=[%s] actual=[%s]", value, {target});
    {statement}
    readback = value.getc(1);
    $display("mid=[%s] actual=[%s] byte=%02h", value, {target}, readback);
    value = {{value, "!"}};
  endtask

  initial begin
{setup}    {target} = "Start";
    {guard} = "Keep";
    saved = {target};
    modify({target});
    $display("after=[%s] saved=[%s] guard=[%s]", {target}, saved, {guard});
  end
endmodule"""
    lrm = "13.5.2" if direction == "ref" else "13.5.1 13.5"
    method = "6.16.8" if update == "substring" else "6.16.2"
    return Case(name, "String formal updates obey the argument direction and preserve copies",
                f"{lrm} {method} 6.16.3",
                "Observe the source through the caller during a task update and again after "
                "return. Compare a string variable and two array element kinds. The saved "
                "copy and a neighbor are guards. The output formal starts with an explicit seed.",
                body, "\n".join(expected) + "\n")


def cases():
    return [make_case(*row) for row in product(("input", "output", "inout", "ref"), LOCATIONS, UPDATES)]
