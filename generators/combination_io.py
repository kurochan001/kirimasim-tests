"""Observable I/O and implicit-sensitivity boundaries from the P1 audit.

Expected values come from byte order, selected locations, sensitivity and
VCD declarations, never from an unsupported diagnostic. Artifact checks run
inside SV, so the existing runners and historical fingerprints stay intact.
"""

from common import Case

NAME = "combination_io"
VERSION = 1
CHAPTER = 21
ISSUE = "https://github.com/kurochan001/kirimasim-tests/issues/21"


def metadata(item: str) -> dict[str, str]:
    return {"issue": ISSUE, "combination_gap": item}


def fread_case(kind: str) -> Case:
    name = "test_gen_comb_fread_" + kind
    declarations = {
        "dynamic_selection": "  byte values[];",
        "struct_array_member": (
            "  typedef struct { byte values[2]; bit [7:0] tag; } row_t;\n"
            "  row_t rows[3];"),
        "struct_multidimensional": (
            "  typedef struct { bit [7:0] first, last; } row_t;\n"
            "  row_t rows[0:1][2:3];"),
    }[kind]
    setup = {
        "dynamic_selection": """
    values = new[3];
    for (int i = 0; i < 3; i++) values[i] = 8'ha0 + i;
    count = $fread(values, fd, 1, 1);
    next_byte = $fgetc(fd);
    $display("count=%0d cells=%h,%h,%h next=%h", count,
             values[0], values[1], values[2], next_byte);
""",
        "struct_array_member": """
    for (int i = 0; i < 3; i++) begin
      rows[i].values[0] = 8'ha0 + i;
      rows[i].values[1] = 8'hb0 + i;
      rows[i].tag = 8'hc0 + i;
    end
    count = $fread(rows, fd, 1, 1);
    next_byte = $fgetc(fd);
    $display("count=%0d", count);
    for (int i = 0; i < 3; i++)
      $display("row%0d=%h,%h,%h", i, rows[i].values[0], rows[i].values[1], rows[i].tag);
    $display("next=%h", next_byte);
""",
        "struct_multidimensional": """
    foreach (rows[i,j]) begin
      rows[i][j].first = 8'haa;
      rows[i][j].last = 8'hbb;
    end
    count = $fread(rows, fd);
    next_byte = $fgetc(fd);
    $display("count=%0d", count);
    for (int i = 0; i < 2; i++)
      for (int j = 2; j < 4; j++)
        $display("row%0d_%0d=%h,%h", i, j, rows[i][j].first, rows[i][j].last);
    $display("next=%h", next_byte);
""",
    }[kind]
    data = ([0xa5, 0x5a] * 4 + [0xee]
            if kind == "struct_multidimensional" else [0x12, 0x34, 0x56, 0x78])
    writes = "\n".join(f'    $fwrite(fd, "%c", 8\'h{value:02x});' for value in data)
    body = f"""module {name};
{declarations}
  int fd, count;
  bit [7:0] next_byte;
  initial begin
    fd = $fopen("{name}.bin", "wb");
    if (fd == 0) $fatal(1, "cannot create input");
{writes}
    $fclose(fd);
    fd = $fopen("{name}.bin", "rb");
    if (fd == 0) $fatal(1, "cannot open input");
{setup.rstrip()}
    $fclose(fd);
    $finish;
  end
endmodule
"""
    expected = {
        "dynamic_selection": "count=1 cells=a0,12,a2 next=34\n",
        "struct_array_member": (
            "count=3\nrow0=a0,b0,c0\nrow1=12,34,56\nrow2=a2,b2,c2\nnext=78\n"),
        "struct_multidimensional": (
            "count=8\nrow0_2=a5,5a\nrow0_3=a5,5a\nrow1_2=a5,5a\nrow1_3=a5,5a\nnext=ee\n"),
    }[kind]
    return Case(
        name, "Binary input traverses typed memory while preserving unselected locations",
        "21.3.4.4 21.3.1 21.3.2",
        "An independently specified byte file is read into a dynamic memory, an array "
        "member of a structure memory, or a multidimensional structure memory. Selected "
        "reads check both untouched neighbours; a following fgetc checks consumption. "
        "The recursive struct layout follows member declaration order. Real members "
        "are excluded pending a separately recorded interpretation of their byte encoding. "
        "The multidimensional case repeats the member pair, checking all locations "
        "without fixing an unconfirmed order between memory dimensions.",
        body, expected, extra=metadata("F01"),
    )


def heap_observations(form: str) -> list[tuple[str, int]]:
    states = [("empty", [], True), ("allocated", [3, 5], True),
              ("unrelated", [3, 9], True), ("element", [7, 9], True),
              ("held", [11, 9], False), ("enabled", [11, 9], True),
              ("grown", [11, 9, 13], True), ("replaced", [1, 2], True),
              ("cleared", [], True)]
    result, previous = [], 0
    for label, values, enabled in states:
        computed = (len(values) if form == "continuous" else
                    100 if not values else 16 * len(values) + values[0])
        value = computed if enabled else previous if form == "latch" else -1
        result.append((label, value))
        previous = value
    return result


def heap_case(container: str, form: str) -> Case:
    name = f"test_gen_comb_heap_sensitivity_{container}_{form}"
    declaration = "int values[$];" if container == "queue" else "int values[];"
    expr = "(values.size() == 0 ? 100 : 16 * values.size() + values[0])"
    body = {
        "comb": f"always_comb result = enabled ? {expr} : -1;",
        "star": f"always @* result = enabled ? {expr} : -1;",
        "continuous": "assign result = enabled ? $size(values) : -1;",
        "latch": f"always_latch if (enabled) result = {expr};",
    }[form]
    allocate = ("values = '{3,5};" if container == "queue" else
                "values = new[2]; values[0] = 3; values[1] = 5;")
    grow = "values.push_back(13);" if container == "queue" else \
        "values = new[3](values); values[2] = 13;"
    clear = "values = {};" if container == "queue" else "values = new[0];"
    lines = ["`timescale 1ns/1ns", f"module {name};", "  " + declaration,
             "  int result;", "  bit enabled;", "  " + body, "  initial begin",
             "    enabled = 0;", "    #1 enabled = 1;", "    #1;",
             '    $display("empty=%0d", result);', "    " + allocate, "    #1;",
             '    $display("allocated=%0d", result);', "    values[1] = 9;", "    #1;",
             '    $display("unrelated=%0d", result);', "    values[0] = 7;", "    #1;",
             '    $display("element=%0d", result);', "    enabled = 0; values[0] = 11;",
             "    #1;", '    $display("held=%0d", result);', "    enabled = 1;", "    #1;",
             '    $display("enabled=%0d", result);', "    " + grow, "    #1;",
             '    $display("grown=%0d", result);', "    values = '{1,2};", "    #1;",
             '    $display("replaced=%0d", result);', "    " + clear, "    #1;",
             '    $display("cleared=%0d", result);', "    $finish;", "  end", "endmodule"]
    clause = {"comb": "9.2.2.2.1 9.2.2.2", "latch": "9.2.2.3 9.2.2.2.1",
              "star": "9.4.2.2", "continuous": "10.3.2"}[form]
    if form == "continuous":
        clause += " 20.7"
    return Case(
        name, "Implicit sensitivity follows container replacement, size and selected values",
        clause + (" 7.10" if container == "queue" else " 7.5.1"),
        "Procedural outputs combine size and the first element; empty containers are "
        "guarded. Continuous assignment queries size only: direct references to dynamic "
        "elements outside procedural blocks are forbidden by 6.21. "
        "Known enable transitions establish the initial observation without relying on "
        "always-star startup. Allocation, an unrelated element, a selected element, "
        "growth, replacement and clearing are separated by one time unit. Latch holds "
        "when disabled; the other forms produce the specified disabled value. No output "
        "is procedurally initialized or written by a second process.",
        "\n".join(lines), "".join(f"{label}={value}\n" for label, value in heap_observations(form)),
        extra=metadata("H01"), chapter=int(clause.split(".")[0]),
    )


def waveform_case(selection: str) -> Case:
    name = "test_gen_comb_vcd_program_interface_" + selection
    dump = ("$dumpvars;" if selection == "all_model" else
            "$dumpvars(0, dut.module_value, dut.bus.bus_value);")
    program_dump = "" if selection == "all_model" else "#0; $dumpvars(0, program_value);"
    body = """`timescale 1ns/1ns
interface comb_wave_bus;
  bit bus_value = 0;
  initial #1 bus_value = 1;
endinterface
program comb_wave_job;
  bit program_value = 0;
  initial begin PROGRAM_DUMP #1 program_value = 1; #20; end
endprogram
module comb_wave_dut;
  bit module_value = 0;
  comb_wave_bus bus();
  comb_wave_job job();
  initial #1 module_value = 1;
endmodule
module NAME;
  comb_wave_dut dut();
  integer fd, rc, size, steps, depth = 0;
  string token, kind, code, reference_name, scope_path = "";
  bit scope_dut = 0, scope_bus = 0, scope_job = 0;
  bit var_dut = 0, var_bus = 0, var_job = 0, ended = 0, invalid_scope = 0;
  function automatic bit suffix(input string path, input string tail);
    if (path.len() < tail.len()) return 0;
    return path.substr(path.len()-tail.len(), path.len()-1) == tail;
  endfunction
  function automatic string parent_scope(input string path);
    for (int i = path.len()-1; i >= 0; i--)
      if (path[i] == ".") begin
        if (i == 0) return "";
        return path.substr(0, i-1);
      end
    return "";
  endfunction
  initial begin
    $dumpfile("NAME.vcd");
    DUMP
    #4 $dumpflush;
    fd = $fopen("NAME.vcd", "r");
    if (fd == 0) $fatal(1, "missing waveform artifact");
    steps = 0;
    while ($fscanf(fd, "%s", token) == 1 && steps < 10000) begin
      steps++;
      if (token == "$scope") begin
        depth++;
        rc = $fscanf(fd, "%s %s", kind, reference_name);
        scope_path = {scope_path, ".", reference_name};
        if (suffix(scope_path, ".dut")) scope_dut = 1;
        if (suffix(scope_path, ".dut.bus")) scope_bus = 1;
        if (suffix(scope_path, ".dut.job")) scope_job = 1;
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token == "$upscope") begin
        if (depth == 0) invalid_scope = 1;
        else depth--;
        scope_path = parent_scope(scope_path);
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token == "$var") begin
        rc = $fscanf(fd, "%s %d %s %s", kind, size, code, reference_name);
        if (size == 1) begin
          if (suffix(scope_path, ".dut") && reference_name == "module_value") var_dut = 1;
          if (suffix(scope_path, ".dut.bus") && reference_name == "bus_value") var_bus = 1;
          if (suffix(scope_path, ".dut.job") && reference_name == "program_value") var_job = 1;
        end
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end else if (token == "$enddefinitions") begin
        ended = 1;
        break;
      end else if (token == "$date" || token == "$version" || token == "$timescale" ||
                   token == "$comment") begin
        do rc = $fscanf(fd, "%s", token); while (rc == 1 && token != "$end");
      end
    end
    $fclose(fd);
    $display("scopes=%b%b%b vars=%b%b%b balanced=%0d ended=%0d", scope_dut, scope_bus,
             scope_job, var_dut, var_bus, var_job,
             scope_path == "" && depth == 0 && !invalid_scope, ended);
    $finish;
  end
endmodule
""".replace("NAME", name).replace("PROGRAM_DUMP", program_dump).replace("DUMP", dump)
    return Case(
        name, "VCD artifacts contain declared module, interface and program variables in their scopes",
        "21.7.1.2 21.7.1.6 21.7.2.1 21.7.2.3 21.7.5",
        "All-model selection or three explicit bit variables request the waveform. The "
        "program requests its own variable, avoiding illegal external program access. "
        "An explicit zero-delay separates that request from file configuration at the "
        "same simulation time. "
        "program stays alive until the observer finishes. After dumpflush, a bounded "
        "token reader checks hierarchical scope suffixes, the variable names and widths, "
        "balanced scopes and enddefinitions. It does not fix scope kind spellings, "
        "identifier codes, header dates, version banners or unrelated declarations. "
        "The reader is part of the stimulus and therefore of the input fingerprint. "
        "A missing scope, variable or artifact cannot pass on exit code alone.",
        body, "scopes=111 vars=111 balanced=1 ended=1\n", extra=metadata("F02"),
    )


def cases() -> list[Case]:
    return [fread_case(kind) for kind in
            ("dynamic_selection", "struct_array_member", "struct_multidimensional")] + [
                heap_case(container, form) for container in ("queue", "dynamic")
                for form in ("comb", "star", "continuous", "latch")] + [
                waveform_case(selection) for selection in ("all_model", "explicit")]
