/*
:name: test_vcd_scope_commands_begin_fork_task
:description: The VCD $scope command gives the type and name of a module, a named sequential block, a named parallel block and a subroutine, $upscope returns one level, and a $var records the name, size, index range and identifier of a variable (IEEE 1800-2023 Section 21.7.2.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.7.2.3 21.7.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vcd_scope_commands_begin_fork_task.expected
*/
// IEEE 1800-2023 §21.7.2.3: $scope gives the type and name of a scope, with
// module for a top or module instance, begin for a named sequential block,
// fork for a named parallel block and task or function for a subroutine;
// $upscope moves to the next higher level; $var records the name, printable
// identifier, bit size and, for a vector, the most and least significant
// indices. §21.7.2.1: these are declaration commands, each ended by $end,
// and Syntax 21-20 makes the index range of a reference optional.
//
// The design has a named begin block with a 4-bit variable, a named fork
// block and a static task. The reader checks a $scope of each type and name,
// the type and size of the reg 4 declaration — with the range [3:0] when it
// is written — and that the scopes balance.

`timescale 1ns/1ns

module test_vcd_scope_commands_begin_fork_task;
  logic top = 1'b1;

  task named_task();
    static logic in_task = 1'b1;
    #6;
  endtask

  // The state of one $var declaration: its type and size as §21.7.2.3
  // requires them, and an index range that is either absent or the one of
  // the declaration.
  function automatic string var_state(string typ, string want_typ, int size,
                                      int want_size, string rng,
                                      string want_rng);
    if (typ != want_typ)
      return $sformatf("%s %0d: type, want %s", typ, size, want_typ);
    if (size != want_size)
      return $sformatf("%s %0d: size, want %0d", typ, size, want_size);
    if (rng != "-" && rng != want_rng)
      return $sformatf("%s %0d: range %s, want %s or none",
                       typ, size, rng, want_rng);
    return $sformatf("%s %0d ok", typ, size);
  endfunction

  // The range of a reference may be a token of its own (nib [3:0]) or part
  // of the reference (nib[3:0]), so a reference can hold the bracket.
  function automatic int bracket_at(string s);
    for (int i = 0; i < s.len(); i++)
      if (s[i] == "[") return i;
    return -1;
  endfunction

  task automatic read_dump();
    int fd, size, depth = 0, max_depth = 0, bracket;
    string token, kind, code, reference, rng, var_text = "";
    bit module_ok = 0, begin_ok = 0, fork_ok = 0, task_ok = 0;
    bit balanced = 0, ended = 0;
    int scopes = 0, upscopes = 0;

    fd = $fopen("scopes.vcd", "r");
    if (fd == 0) $fatal(1, "the dump file is missing");
    while ($fscanf(fd, "%s", token) == 1) begin
      if (token == "$scope") begin
        void'($fscanf(fd, "%s %s", kind, reference));
        depth++;
        if (depth > max_depth) max_depth = depth;
        if (kind == "module" && reference == "test_vcd_scope_commands_begin_fork_task")
          module_ok = 1;
        if (kind == "begin" && reference == "named_begin") begin_ok = 1;
        if (kind == "fork" && reference == "named_fork") fork_ok = 1;
        if (kind == "task" && reference == "named_task") task_ok = 1;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$upscope") begin
        depth--;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$var") begin
        void'($fscanf(fd, "%s %d %s %s", kind, size, code, reference));
        rng = "-";
        bracket = bracket_at(reference);
        if (bracket >= 0) begin
          rng = reference.substr(bracket + 1, reference.len() - 2);
          reference = reference.substr(0, bracket - 1);
          void'($fscanf(fd, "%s", token));
        end else begin
          void'($fscanf(fd, "%s", token));
          if (token != "$end") begin
            rng = token.substr(1, token.len() - 2);
            void'($fscanf(fd, "%s", token));
          end
        end
        if (reference == "nib")
          var_text = var_state(kind, "reg", size, 4, rng, "3:0");
      end else if (token == "$enddefinitions") begin
        ended = 1;
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end else if (token == "$comment" || token == "$date" || token == "$version" ||
                   token == "$timescale") begin
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
      end
    end
    $fclose(fd);
    balanced = depth == 0 && max_depth >= 3;
    if (var_text == "") var_text = "missing";
    $display("the module scope is named: %0d", module_ok);
    $display("the named begin block is a begin scope: %0d", begin_ok);
    $display("the named fork block is a fork scope: %0d", fork_ok);
    $display("the task is a task scope: %0d", task_ok);
    $display("the vector var: %s", var_text);
    $display("one upscope for every scope: %0d", upscopes == scopes);
    $display("the scopes nest and balance: %0d", balanced);
    $display("enddefinitions ends the declarations: %0d", ended);
  endtask

  initial begin : named_begin
    static logic [3:0] nib = 4'h5;
    fork : named_fork
      begin
        static logic in_fork = 1'b0;
        #2 in_fork = 1'b1;
        #4;
      end
    join
  end

  initial begin
    $dumpfile("scopes.vcd");
    $dumpvars(0, test_vcd_scope_commands_begin_fork_task);
    fork
      named_task();
    join_none
    #3 $dumpflush;
    read_dump();
  end
endmodule
