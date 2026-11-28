# Copyright (c) 2026 The kirimasim Authors
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
"""Event-keyed associative element updates, expression values and deletion.

The reference uses symbolic event identities. A direct handle, an alias, and
an array element holding the same handle all denote one entry. The null key
and a different event are independent of that entry.
"""

from itertools import product
from operator import add, sub, xor

from common import Case

NAME = "event_key_updates"
VERSION = 1
CHAPTER = 7

KEYS = {"direct": ("primary", "primary"), "alias": ("same_event", "primary"),
        "element": ("handles[1]", "primary"), "null": ("no_event", "null")}
UPDATES = {
    "assign": ("{item} = {item} + 7;", add, 7, None),
    "add": ("{item} += 7;", add, 7, None),
    "sub": ("{item} -= 3;", sub, 3, None),
    "xor": ("{item} ^= 49;", xor, 49, None),
    "postinc": ("result = {item}++;", add, 1, "before"),
    "predec": ("result = --{item};", sub, 1, "after"),
}


def make_case(key_form, update):
    key_expr, identity = KEYS[key_form]
    statement, compute, operand, observed = UPDATES[update]
    values = {"primary": 13, "other": 59, "null": 23}
    before, other, null = values.values()
    result = -1
    if observed == "before":
        result = values[identity]
    values[identity] = compute(values[identity], operand)
    if observed == "after":
        result = values[identity]
    name = f"test_gen_event_key_update_{key_form}_{update}"
    lines = [f"module {name};", "  typedef event key_t;",
             "  key_t primary, other, same_event, no_event, handles[2];", "  int values[key_t];",
             "  int result = -1;", "  initial begin", "    same_event = primary;",
             "    handles[1] = primary;", "    no_event = null;",
             f"    values[primary] = {before}; values[other] = {other}; values[no_event] = {null};",
             '    $display("before=%0d/%0d/%0d count=%0d",',
             "             values[primary], values[other], values[no_event], values.num());",
             "    " + statement.format(item=f"values[{key_expr}]"),
             '    $display("after=%0d/%0d/%0d count=%0d expression=%0d",',
             "             values[same_event], values[other], values[no_event], values.num(), result);",
             f"    values.delete({key_expr});",
             '    $display("exists=%0d/%0d/%0d count=%0d",',
             "             values.exists(primary), values.exists(other), values.exists(no_event),",
             "             values.num());", "    $finish(0);", "  end", "endmodule"]
    expected = (f"before={before}/{other}/{null} count=3\n"
                f"after={values['primary']}/{values['other']}/{values['null']} "
                f"count=3 expression={result}\n"
                f"exists={int(identity != 'primary')}/1/{int(identity != 'null')} count=2\n")
    lrm = "7.8.5 7.9.1 7.9.2 7.9.3 15.5.5.1 15.5.5.3 " + ("11.4.2" if observed else "11.4.1")
    return Case(name, "Updating an event-keyed associative element preserves key identity", lrm,
                "Read back the primary entry through its alias and keep a distinct event "
                "and null entry as controls. Observe the changed value and the result of "
                "prefix or postfix operations, then delete through the same key expression "
                "and check that no other entry was removed.", "\n".join(lines), expected)


def cases():
    return [make_case(*row) for row in product(KEYS, UPDATES)]
