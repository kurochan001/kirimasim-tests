"""Regression witnesses for static references, deferred writes and copyback.

The expected values come from 10.4.2/9.4.5 reservation and update rules,
13.5 value/reference transfer, 7.6 declaration-order correspondence and
6.16 character selection. No current unsupported diagnostic is expected.
These finite mechanism witnesses do not claim general t-way coverage.
"""

from common import Case
from interaction_cond import literal

NAME = "combination_nba"
VERSION = 1
CHAPTER = 10
ISSUE = "https://github.com/kurochan001/kirimasim-tests/issues/21"


def meta(candidate: str) -> dict[str, str]:
    return {"issue": ISSUE, "combination_gap": candidate}


def bits(value: int, width: int) -> str:
    return f"{value & ((1 << width) - 1):0{width}b}"


def delayed_ref_case(width: int, state: str) -> Case:
    name = f"test_gen_ref_static_delayed_nba_w{width}_{state}"
    a = bits(0xa5, width) if state == "bit" else "x" + "01" * (width // 2)
    b = bits(0x3c, width) if state == "bit" else "z" + "10" * (width // 2)
    zero = "0" * width
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef {state} [{width - 1}:0] word_t;",
             "  word_t first, second, source_a, source_b;", "  integer returned;",
             "  task automatic reserve(ref static word_t target, input word_t data);",
             "    target <= #2 data;", "    data = '0;", "    returned++;", "  endtask",
             "  initial begin", "    first = '0; second = '0; returned = 0;",
             f"    source_a = {literal(a)};", f"    source_b = {literal(b)};",
             "    reserve(first, source_a);", "    reserve(second, source_b);",
             "    source_a = '0; source_b = '0;",
             '    $display("returned=%0d t=%0d first=%b second=%b",',
             "             returned, $time, first, second);", "    #1;",
             '    $display("before t=%0d first=%b second=%b", $time, first, second);',
             "    #1;",
             '    $display("active t=%0d first=%b second=%b", $time, first, second);',
             "    #1;",
             '    $display("after t=%0d first=%b second=%b sources=%b,%b",',
             "             $time, first, second, source_a, source_b);",
             "    $finish;", "  end", "endmodule"]
    expected = (f"returned=2 t=0 first={zero} second={zero}\n"
                f"before t=1 first={zero} second={zero}\n"
                f"active t=2 first={zero} second={zero}\n"
                f"after t=3 first={a} second={b} sources={zero},{zero}\n")
    return Case(name, "Delayed NBA through ref static survives two automatic task returns",
                "10.4.2 9.4.5 13.5.2 4.4.2.2 4.4.2.4",
                "Two calls reserve writes to different static actuals. The automatic input "
                "is changed before each return, and both source variables change after the "
                "calls. Active observations at the update time precede NBA; the next tick "
                "checks both captured values and target identities after both frames ended.",
                "\n".join(lines), expected, fourstate=state == "logic", extra=meta("N01"))


def event_array_case(width: int, descending: bool) -> Case:
    direction = "descending" if descending else "ascending"
    name = f"test_gen_ref_static_array_event_nba_w{width}_{direction}"
    left, right = (3, 2) if descending else (2, 3)
    before = (bits(0x11, width), bits(0x22, width))
    data = bits(0x5a, width) if width == 8 else "x" + "10" * (width // 2)
    zero = "0" * width
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef logic [{width - 1}:0] word_t;",
             f"  word_t values[{left}:{right}];", "  word_t source;", "  bit clk;",
             "  integer selected, returned;",
             f"  task automatic reserve(ref static word_t target[{left}:{right}],",
             "                         input integer index, input word_t data);",
             "    target[index] <= @(posedge clk) data;",
             f"    index = {right};", "    data = '0;", "    returned++;", "  endtask",
             "  initial begin", "    clk = 0; returned = 0;",
             f"    values[{left}] = {literal(before[0])};",
             f"    values[{right}] = {literal(before[1])};",
             f"    source = {literal(data)};", f"    selected = {left};",
             "    reserve(values, selected, source);", f"    selected = {right};", "    source = '0;",
             '    $display("returned=%0d t=%0d values=%b,%b index=%0d source=%b",',
             f"             returned, $time, values[{left}], values[{right}], selected, source);",
             "    #1;",
             '    $display("before t=%0d values=%b,%b",',
             f"             $time, values[{left}], values[{right}]);",
             "    #1; clk = 1; #0;",
             '    $display("inactive t=%0d values=%b,%b",',
             f"             $time, values[{left}], values[{right}]);",
             "    #1;",
             '    $display("after t=%0d values=%b,%b",',
             f"             $time, values[{left}], values[{right}]);",
             "    $finish;", "  end", "endmodule"]
    expected = (f"returned=1 t=0 values={before[0]},{before[1]} index={right} source={zero}\n"
                f"before t=1 values={before[0]},{before[1]}\n"
                f"inactive t=2 values={before[0]},{before[1]}\n"
                f"after t=3 values={data},{before[1]}\n")
    return Case(name, "Event NBA captures an element through a static array reference before task return",
                "10.4.2 9.4.5 13.5.2 7.4.1 4.4.2.3 4.4.2.4",
                "The array and clock are static. The callee changes its input index and data "
                "after reservation; the caller also changes its source and index. A zero "
                "delay after the edge observes Inactive before NBA, then the following tick "
                "checks the originally selected element and its untouched neighbour.",
                "\n".join(lines), expected, fourstate=width > 8, extra=meta("N02"))


def nested_event_case(width: int, valid: bool) -> Case:
    suffix = "valid" if valid else "outside_parent"
    name = f"test_gen_ref_static_nested_packed_event_nba_w{width}_{suffix}"
    index = width - 1 if valid else width + 1
    guard = bits((1 << (width - 1)) | (1 << (width // 2)) | 1, width)
    child = "0" * width
    value = "z" if valid and width > 8 else "1"
    final_child = value + child[1:] if valid else child
    initial = guard + child
    final = guard + final_child
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef logic [1:0][{width - 1}:0] packed_t;", "  packed_t values;",
             "  logic source;", "  bit clk;", "  integer selected, returned;",
             "  task automatic reserve(ref static packed_t target,",
             "                         input integer index, input logic data);",
             "    target[0][index] <= @(posedge clk) data;", "    index = 0; data = 0;",
             "    returned++;", "  endtask", "  initial begin", "    clk = 0; returned = 0;",
             f"    values = {literal(initial)};", f"    selected = {index};",
             f"    source = 1'b{value};", "    reserve(values, selected, source);",
             "    selected = 0; source = 0;",
             '    $display("returned=%0d t=%0d values=%b", returned, $time, values);',
             "    #1;", '    $display("before t=%0d values=%b", $time, values);',
             "    #1; clk = 1; #0;",
             '    $display("inactive t=%0d values=%b", $time, values);', "    #1;",
             '    $display("after t=%0d values=%b guard=%b child=%b",',
             "             $time, values, values[1], values[0]);",
             "    $finish;", "  end", "endmodule"]
    expected = (f"returned=1 t=0 values={initial}\nbefore t=1 values={initial}\n"
                f"inactive t=2 values={initial}\n"
                f"after t=3 values={final} guard={guard} child={final_child}\n")
    return Case(name, "Event NBA through a static packed reference keeps child bounds and captured index",
                "10.4.2 9.4.5 13.5.2 11.5.1 7.4.5 4.4.2.3 4.4.2.4",
                "A selected bit lies inside one packed parent or just beyond that parent. "
                "The latter write must be ignored rather than spilling into its neighbour. "
                "The task returns before the event and both index and data are changed. "
                "The full object, guarded parent and selected child are observed after NBA.",
                "\n".join(lines), expected, fourstate=value == "z", extra=meta("N03"))


def string_delay_case(index: int) -> Case:
    name = f"test_gen_string_character_delayed_nba_index{index}"
    before = "ABCD"
    updated = list(before)
    updates = ((0, "w"), (3, "z")) if index == 1 else ((0, "w"), (1, "y"))
    for position, char in updates:
        updated[position] = char
    pending = "".join(updated)
    value = "Q" if index == 1 else "Z"
    updated[index] = value
    final = "".join(updated)
    lines = ["`timescale 1ns/1ns", f"module {name};", "  string text;",
             "  integer selected;", "  byte source;", "  initial begin", f'    text = "{before}";',
             f"    selected = {index}; source = 8'h{ord(value):02x};",
             "    text[selected] <= #2 source;", f"    selected = {3 if index == 1 else 0};",
             "    source = 0;"]
    lines += [f"    text[{position}] = 8'h{ord(char):02x};" for position, char in updates]
    lines += ['    $display("scheduled t=%0d text=%s len=%0d index=%0d source=%0d",',
              "             $time, text, text.len(), selected, source);", "    #1;",
              '    $display("before t=%0d text=%s", $time, text);', "    #1;",
              '    $display("active t=%0d text=%s", $time, text);', "    #1;",
              '    $display("after t=%0d text=%s len=%0d", $time, text, text.len());',
              "    $finish;", "  end", "endmodule"]
    expected = (f"scheduled t=0 text={pending} len=4 index={3 if index == 1 else 0} source=0\n"
                f"before t=1 text={pending}\nactive t=2 text={pending}\n"
                f"after t=3 text={final} len=4\n")
    return Case(name, "Delayed NBA of a static string character captures index and byte while guards change",
                "10.4.2 9.4.5 6.16 6.16.1 4.4.2.2 4.4.2.4",
                "The string has static lifetime and its length remains four. The RHS byte "
                "and selected index change after scheduling; other characters are written "
                "before the update and must survive. These cases deliberately do not "
                "claim the separate question of resizing a string during a pending write.",
                "\n".join(lines), expected, extra=meta("N04"))


def slice_copyback_case(descending: bool, mode: str) -> Case:
    direction = "descending" if descending else "ascending"
    name = f"test_gen_fixed_array_slice_{mode}_copyback_{direction}"
    bounds = (5, 2) if descending else (2, 5)
    order = list(range(bounds[0], bounds[1] + (-1 if descending else 1), -1 if descending else 1))
    first, one, two, last = order
    initial = [10, 20, 30, 40]
    result = [161, 178] if mode == "output" else [21, 32]
    assignments = ["    target[0] = 8'ha1; target[1] = 8'hb2;"] if mode == "output" else \
        ["    target[0] = target[0] + 1; target[1] = target[1] + 2;"]
    values_expr = ", ".join(f"values[{i}]" for i in order)
    lines = ["`timescale 1ns/1ns", f"module {name};", "  typedef logic [7:0] word_t;",
             f"  word_t values[{bounds[0]}:{bounds[1]}];",
             f"  task automatic edit({mode} word_t target[0:1]);"]
    lines += assignments
    lines += ['    $display("inside t=%0d values=%0d,%0d,%0d,%0d formal=%0d,%0d",',
              f"             $time, {values_expr}, target[0], target[1]);", "    #1;",
              f"    values[{first}] = 8'h55; values[{last}] = 8'h66;",
              '    $display("waiting t=%0d values=%0d,%0d,%0d,%0d",',
              f"             $time, {values_expr});", "    #1;", "  endtask", "  initial begin"]
    lines += [f"    values[{i}] = {v};" for i, v in zip(order, initial)]
    lines += [f"    edit(values[{one}:{two}]);",
              '    $display("returned t=%0d values=%0d,%0d,%0d,%0d",',
              f"             $time, {values_expr});", "    $finish;", "  end", "endmodule"]
    expected = (f"inside t=0 values=10,20,30,40 formal={result[0]},{result[1]}\n"
                "waiting t=1 values=85,20,30,102\n"
                f"returned t=2 values=85,{result[0]},{result[1]},102\n")
    return Case(name, "Fixed array slice copyback waits for return and preserves unsliced neighbours",
                "13.5 13.5.1 7.4.6 7.6",
                "A two-element slice with nonzero indices is copied through an automatic "
                "output or inout formal with different bounds. Formal writes are observed "
                "while the actual slice is unchanged. Guard elements change during the "
                "call; return copies back only the selected slice in declaration order.",
                "\n".join(lines), expected, extra=meta("A04"), chapter=13)


def cases() -> list[Case]:
    return ([delayed_ref_case(8, "bit"), delayed_ref_case(65, "logic")]
            + [event_array_case(width, descending) for width in (8, 65)
               for descending in (False, True)]
            + [nested_event_case(width, valid) for width in (8, 65) for valid in (True, False)]
            + [string_delay_case(index) for index in (1, 3)]
            + [slice_copyback_case(descending, mode) for descending in (False, True)
               for mode in ("output", "inout")])
