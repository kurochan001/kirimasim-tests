"""Observable aggregate/selection/streaming boundaries tracked by issue 21.

Expectations use structure field values, independently addressed packed bits,
and nibble permutations. No current simulator diagnostic is an expectation.
Existing with-range streaming tests are reused by the accompanying inventory.
"""

from itertools import product

from common import Case

NAME = "combination_aggregates"
VERSION = 1
CHAPTER = 13


def case(name: str, gap: str, description: str, clauses: str, comment: str,
         body: str, expected: str, *, fourstate: bool = False) -> Case:
    return Case(name, description, clauses, comment, body, expected,
                fourstate=fourstate, chapter=int(clauses.split()[0].split(".")[0]),
                extra={"issue": "21", "combination_gap": gap})


def struct_ref() -> Case:
    name = "test_gen_combo_struct_ref_immediate_and_return"
    body = f"""`timescale 1ns/1ns
module {name};
  typedef struct {{ int value; int guard; logic [7:0] tag; }} item_t;
  item_t actual;
  task automatic edit(ref item_t r);
    r.value = r.value + 7;
    $display("inside=%0d %0d %h time=%0d", actual.value, actual.guard, actual.tag, $time);
    #1;
    r.tag = 8'hc3;
  endtask
  initial begin
    actual.value = 10; actual.guard = 91; actual.tag = 8'h5a;
    edit(actual);
    $display("returned=%0d %0d %h time=%0d", actual.value, actual.guard, actual.tag, $time);
    actual.value = 30;
    edit(actual);
    $display("again=%0d %0d %h time=%0d", actual.value, actual.guard, actual.tag, $time);
    $finish;
  end
endmodule"""
    return case(name, "A01", "Unpacked structure ref writes are visible before task return",
                "13.5.2 7.2 6.21 9.4.1",
                "The actual is a static whole unpacked structure of the same typedef. "
                "Inside the task, reading the actual proves immediate aliasing rather "
                "than copyback. A delayed member write and a second call preserve the "
                "untouched guard and demonstrate continued writes to the actual.",
                body, "inside=17 91 5a time=0\nreturned=17 91 c3 time=1\n"
                "inside=37 91 c3 time=1\nagain=37 91 c3 time=2\n")


def automatic_array(member: bool) -> Case:
    suffix = "member" if member else "elements"
    name = f"test_gen_combo_struct_array_automatic_{suffix}"
    declaration = ("  typedef struct { int values[2]; int guard; } item_t;" if member else
                   "  typedef struct { int value; int guard; } item_t;")
    local = "    item_t local_item;" if member else "    item_t local_items[2];"
    fields = (["local_item.values[0]", "local_item.values[1]", "local_item.guard"] if member else
              ["local_items[0].value", "local_items[1].value", "local_items[1].guard"])
    body = ["`timescale 1ns/1ns", f"module {name};", declaration,
            "  task automatic retain(input int seed, input int ticks);", local,
            f"    {fields[0]} = seed;", f"    {fields[1]} = seed + 1;",
            f"    {fields[2]} = seed + 90;", "    #(ticks);",
            '    $display("held=%0d %0d %0d time=%0d",',
            f"             {fields[0]}, {fields[1]}, {fields[2]}, $time);",
            f"    {fields[0]} = seed + 7;", "    #1;",
            '    $display("changed=%0d %0d %0d time=%0d",',
            f"             {fields[0]}, {fields[1]}, {fields[2]}, $time);",
            "  endtask", "  initial begin", "    fork", "      retain(10, 2);",
            "      begin #1; retain(30, 4); end", "    join", "    retain(50, 1);",
            "    $finish;", "  end", "endmodule"]
    expected = "".join(f"held={seed} {seed + 1} {seed + 90} time={time}\n"
                       f"changed={seed + 7} {seed + 1} {seed + 90} time={time + 1}\n"
                       for seed, time in ((10, 2), (30, 5), (50, 7)))
    return case(name, "A03" if member else "A02",
                "Overlapping automatic structure arrays retain independent values across waits",
                "6.21 7.2 7.4.2 9.3.2 9.4.1",
                "Two calls overlap but print at distinct times (2/3 and 5/6), followed "
                "by a third fresh call. Each call changes one element while another "
                "element and its guard retain their own seed. Array storage is either "
                "an unpacked structure member or an array of unpacked structures.",
                "\n".join(body), expected)


def array_input(descending: bool) -> Case:
    name = "test_gen_combo_struct_array_input_copy_" + ("descending" if descending else "ascending")
    left, right = (3, 2) if descending else (2, 3)
    body = f"""`timescale 1ns/1ns
module {name};
  typedef struct {{ int value; logic [7:0] tag; }} item_t;
  item_t actual[{left}:{right}];
  task automatic edit_copy(input item_t values[0:1]);
    $display("copy=%0d %h %0d %h", values[0].value, values[0].tag,
             values[1].value, values[1].tag);
    values[0].value = 99;
    #1;
    values[1].value = 77;
    $display("local=%0d %h %0d %h", values[0].value, values[0].tag,
             values[1].value, values[1].tag);
    $display("inside_actual=%0d %h %0d %h", actual[{left}].value, actual[{left}].tag,
             actual[{right}].value, actual[{right}].tag);
  endtask
  initial begin
    actual[{left}].value = 10; actual[{left}].tag = 8'ha1;
    actual[{right}].value = 20; actual[{right}].tag = 8'hb2;
    edit_copy(actual);
    $display("returned=%0d %h %0d %h", actual[{left}].value, actual[{left}].tag,
             actual[{right}].value, actual[{right}].tag);
    $finish;
  end
endmodule"""
    return case(name, "A02", "Input arrays of unpacked structures copy in declaration order",
                "13.5.1 7.6 7.2",
                "The formal array has bounds 0:1 and the actual has nonzero ascending "
                "or descending bounds. Equal element counts and the same structure "
                "typedef make them assignment compatible. Both formal elements change "
                "around a wait, while caller fields remain unchanged before and after return.",
                body, "copy=10 a1 20 b2\nlocal=99 a1 77 b2\n"
                "inside_actual=10 a1 20 b2\nreturned=10 a1 20 b2\n")


def packed_runtime(parent_up: bool, child_up: bool, binary: bool) -> Case:
    # Eight rows cover parent direction x child direction x state; update
    # parity balances blocking/NBA and every pair involving update.
    nba = parent_up ^ child_up ^ binary
    state, update = ("bit" if binary else "logic"), ("nba" if nba else "blocking")
    name = (f"test_gen_combo_packed_parent_runtime_{'a' if parent_up else 'd'}"
            f"{'a' if child_up else 'd'}_{state}_{update}")
    pl, pr = (2, 3) if parent_up else (3, 2)
    cl, cr = (0, 32) if child_up else (32, 0)
    rows, columns = [pl, pr], list(range(cl, cr + (1 if child_up else -1), 1 if child_up else -1))
    initial = int("10" * 33, 2)
    target = initial
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  {state} [{pl}:{pr}][{cl}:{cr}] target;", "  integer parent_index, child_index;",
             "  logic incoming;", "  initial begin", f"    target = 66'h{initial:017x};"]
    expected = [f"initial={initial:066b}"]
    lines.append('    $display("initial=%b", target);')
    operations = [(pl, cl), (pr, cr), (pl, 16), (pl, 33), (4, cl), (pr, -1)]
    for phase, (parent, child) in enumerate(operations):
        valid = parent in rows and child in columns
        offset = 65 - (rows.index(parent) * 33 + columns.index(child)) if valid else None
        old = ((target >> offset) & 1) if valid else (0 if binary else "x")
        incoming = 1 - old if valid else 1
        before = target
        if valid:
            target ^= 1 << offset
        lines += [f"    parent_index = {parent}; child_index = {child}; incoming = 1'b{incoming};",
                  f'    $display("p{phase}_read=%b", target[parent_index][child_index]);',
                  f"    target[parent_index][child_index] {'<=' if nba else '='} incoming;",
                  "    parent_index = 4; child_index = 34; incoming = ~incoming;",
                  f'    $display("p{phase}_scheduled=%b", target);', "    #1;",
                  f'    $display("p{phase}_final=%b", target);']
        expected += [f"p{phase}_read={old}",
                     f"p{phase}_scheduled={(before if nba else target):066b}",
                     f"p{phase}_final={target:066b}"]
    lines += ["    $finish;", "  end", "endmodule"]
    return case(name, "S01", "Runtime parent and child selects retain packed window bounds",
                "11.5.1 7.4.1 7.4.5 " + ("10.4.2" if nba else "10.4.1"),
                "Two 33-bit packed elements use nonzero parent bounds and both index "
                "directions. Runtime selections flip the two corners and an interior "
                "bit; child indices 33 and -1 and parent index 4 are outside their "
                "own ranges. Invalid writes preserve the complete 66-bit vector, "
                "rather than spilling into a neighbouring element. Invalid reads "
                "give X for logic or zero for bit. Indices and data change immediately "
                "after scheduling, exposing NBA target/value capture without races.",
                "\n".join(lines), "\n".join(expected) + "\n", fourstate=not binary)


def stream_string() -> Case:
    name = "test_gen_combo_stream_string_target_resize"
    body = f"""module {name};
  string text;
  logic [7:0] head, tail;
  initial begin
    text = "previous";
    {{>>{{head, text, tail}}}} = 40'h11_414243_ff;
    $display("first=%h %0d %s %h", head, text.len(), text, tail);
    {{>>{{head, text, tail}}}} = 32'h22_7879_ee;
    $display("second=%h %0d %s %h", head, text.len(), text, tail);
    $finish;
  end
endmodule"""
    return case(name, "S02", "Unpacking into a string consumes the remaining bytes and resizes it",
                "11.4.14.3 11.4.14.4 6.24.3",
                "The string is the first and only dynamically sized target between "
                "two fixed byte targets. It consumes three and then two bytes, in "
                "most-significant-byte order. Both lengths and all characters are "
                "observed, proving replacement rather than preservation of old suffixes.",
                body, "first=11 3 ABC ff\nsecond=22 2 xy ee\n")


def stream_nested(outer_left: bool, inner_left: bool) -> Case:
    name = f"test_gen_combo_stream_nested_target_{'l' if outer_left else 'r'}{'l' if inner_left else 'r'}"
    outer, inner = ("<<4" if outer_left else ">>"), ("<<4" if inner_left else ">>")
    lines = [f"module {name};", "  logic [7:0] target;", "  logic [3:0] guard;", "  initial begin"]
    expected = []
    for phase, value in enumerate(("a3c", "19f")):
        generic = value[::-1] if outer_left else value
        word = generic[:2][::-1] if inner_left else generic[:2]
        lines += ["    target = 8'h55; guard = 4'h6;",
                  f"    {{{outer}{{{{{inner}{{target}}}}, guard}}}} = 12'h{value};",
                  f'    $display("p{phase}=%h %h", target, guard);']
        expected.append(f"p{phase}={word} {generic[2]}")
    lines += ["    $finish;", "  end", "endmodule"]
    return case(name, "S02", "Nested streaming targets apply each unpack permutation",
                "11.4.14.3 11.4.14.2 11.4.14",
                "The outer 12-bit stream contains an inner 8-bit streaming target "
                "followed by a separate 4-bit target. Each leftward stream reverses "
                "4-bit blocks; rightward streams keep their order. Two asymmetric "
                "inputs distinguish the outer and inner permutations independently.",
                "\n".join(lines), "\n".join(expected) + "\n")


def cases() -> list[Case]:
    return ([struct_ref(), automatic_array(False), array_input(False), array_input(True),
             automatic_array(True)]
            + [packed_runtime(*row) for row in product((False, True), repeat=3)]
            + [stream_string()]
            + [stream_nested(*row) for row in product((False, True), repeat=2)])
