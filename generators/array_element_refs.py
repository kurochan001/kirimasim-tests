"""Element reference identity across dynamic and associative array updates."""

from common import Case

NAME = "array_element_refs"
VERSION = 1
CHAPTER = 13
WIDTHS = (1, 8, 32, 33, 65)
OPERATIONS = ("dynamic_grow_copy", "dynamic_shrink_copy", "dynamic_equal_assignment",
              "dynamic_delete_recreate", "dynamic_write_other",
              "associative_delete_held", "associative_delete_other", "associative_delete_all")


def literal(width, value):
    return f"{width}'b{value:0{width}b}"


def decimal(width, signed, value):
    return value - (1 << width) if signed and value & (1 << (width - 1)) else value


def dump_expected(tag, width, values):
    return [f"{tag} size={len(values)}"] + [
        f"{tag} item[{index}]={value:0{width}b}" for index, value in sorted(values.items())]


def make_case(operation, width, signed):
    sign = "signed" if signed else "unsigned"
    associative = operation.startswith("associative_")
    name = f"test_gen_array_ref_{operation}_w{width}_{sign}"
    full = (1 << width) - 1
    first = sum(1 << index for index in range(0, width, 2))
    second = full ^ first
    indices = (-7, 4, 19) if associative else (0, 1, 2)
    selected = indices[1]
    initial = {indices[0]: full, selected: 0, indices[2]: first}
    live = {indices[0]: full, selected: first, indices[2]: first}
    final = dict(live)
    erase_expected = []
    if operation == "dynamic_grow_copy":
        mutation = ["    data = new[4](data);"]
        final[3] = 0
    elif operation == "dynamic_shrink_copy":
        mutation = ["    data = new[2](data);"]
        del final[2]
    elif operation == "dynamic_equal_assignment":
        mutation = ["    data = replacement;"]
    elif operation == "dynamic_delete_recreate":
        mutation = ["    data.delete();", '    $display("erased size=%0d", data.size());',
                    "    data = new[3];", f"    data[0] = {literal(width, full)};",
                    "    data[1] = FIRST;", "    data[2] = FIRST;"]
        erase_expected = ["erased size=0"]
    elif operation == "dynamic_write_other":
        mutation = ["    data[0] = SECOND;"]
        final[0] = second
        final[selected] = second
    elif operation == "associative_delete_held":
        mutation = ["    data.delete(4);",
                    '    $display("erased exists=%0d size=%0d", data.exists(4), data.num());',
                    "    data[4] = FIRST;"]
        erase_expected = ["erased exists=0 size=2"]
    elif operation == "associative_delete_other":
        mutation = ["    data.delete(-7);"]
        del final[-7]
        final[selected] = second
    else:
        assert operation == "associative_delete_all"
        mutation = ["    data.delete();", '    $display("erased size=%0d", data.num());',
                    f"    data[-7] = {literal(width, full)};",
                    "    data[4] = FIRST;", "    data[19] = FIRST;"]
        erase_expected = ["erased size=0"]
    size_method = "num" if associative else "size"
    lines = ["`timescale 1ns/1ns", f"module {name};",
             f"  typedef bit {sign} [{width - 1}:0] word_t;",
             f"  localparam word_t FIRST = {literal(width, first)};",
             f"  localparam word_t SECOND = {literal(width, second)};",
             "  word_t data[int];" if associative else "  word_t data[];",
             "  word_t retained, written;"]
    if operation == "dynamic_equal_assignment":
        lines.append("  word_t replacement[];")
    lines += ["  task automatic dump(input string tag);",
              f'    $display("%s size=%0d", tag, data.{size_method}());',
              '    foreach (data[i]) $display("%s item[%0d]=%b", tag, i, data[i]);',
              "  endtask", "  task automatic inspect(ref word_t held,",
              "                         output word_t old_value, new_value);",
              '    $display("entry held=%b", held);', "    held = FIRST;",
              '    $display("prewrite held=%b decimal=%0d", held, held);',
              "    #2;", "    old_value = held;",
              '    $display("retained held=%b", held);', "    held = SECOND;",
              "    new_value = held;",
              '    $display("write held=%b decimal=%0d", held, held);',
              "    #2;", "  endtask", "  initial begin"]
    if not associative:
        lines.append("    data = new[3];")
    lines += [f"    data[{index}] = {literal(width, value)};" for index, value in initial.items()]
    if operation == "dynamic_equal_assignment":
        lines += ["    replacement = new[3];"] + [
            f"    replacement[{index}] = {literal(width, value)};" for index, value in live.items()]
    lines += ["    fork", f"      inspect(data[{selected}], retained, written);",
              "      begin", "        #1;", '        dump("live");',
              *["    " + line for line in mutation],
              "        #2;", '        dump("inside");', "      end", "    join",
              '    $display("return retained=%b written=%b", retained, written);',
              '    dump("returned");', "  end", "endmodule"]
    expected = [f"entry held={0:0{width}b}",
                f"prewrite held={first:0{width}b} decimal={decimal(width, signed, first)}",
                *dump_expected("live", width, live), *erase_expected,
                f"retained held={first:0{width}b}",
                f"write held={second:0{width}b} decimal={decimal(width, signed, second)}",
                *dump_expected("inside", width, final),
                f"return retained={first:0{width}b} written={second:0{width}b}",
                *dump_expected("returned", width, final)]
    action = operation.removeprefix("associative_").removeprefix("dynamic_").replace("_", " ")
    return Case(
        name=name,
        description=f"{width}-bit {sign} element ref identity across {action} in a "
                    f"{'associative' if associative else 'dynamic'} array",
        lrm="13.5.2 7.9.2 7.8.4 9.3.2" if associative else "13.5.2 7.5.1 7.5.3 7.6 9.3.2",
        comment="IEEE 1800-2023 13.5.2 B009 requires ref writes to reach the caller "
                "immediately; the live dump occurs before the called task returns. "
                "B013-B014 retain a removed element within the task but detach its "
                "writes from replacement storage. Dynamic allocation, whole-array "
                "assignment and deleting the held associative element outdate the "
                "reference, even when the replacement has equal values or the same "
                "index. Updating or deleting a different element preserves it. "
                "The shrink retains the held numeric index. Assignment uses a "
                "separate same-value array, not self-assignment. Complementary "
                "writes differ even at one bit. The complete container is dumped "
                "during the call and after return. The caller mutates at time 1, "
                "the task writes at time 2, and the caller observes at time 3 before "
                "return at time 4. These separated times avoid scheduling races. "
                "No absent associative key is looked up.",
        body="\n".join(lines) + "\n", expected="\n".join(expected) + "\n")


def cases():
    return [make_case(operation, width, signed) for operation in OPERATIONS
            for width in WIDTHS for signed in (False, True)]
