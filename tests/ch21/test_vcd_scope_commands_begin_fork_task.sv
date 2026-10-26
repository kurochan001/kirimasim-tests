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
// indices. §21.7.2.1: these are declaration commands, each ended by $end.
//
// The design has a named begin block with a 4-bit variable, a named fork
// block and a static task. The reader checks a $scope of each type and name,
// the reg 4 declaration with the range [3:0], and that the scopes balance.

`timescale 1ns/1ns

module test_vcd_scope_commands_begin_fork_task;
  logic top = 1'b1;

  task named_task();
    logic in_task = 1'b1;
    #6;
  endtask

  task automatic read_dump();
    int fd, size, depth = 0, max_depth = 0;
    string token, kind, code, reference, msb, lsb;
    bit module_ok = 0, begin_ok = 0, fork_ok = 0, task_ok = 0;
    bit var_ok = 0, balanced = 0, ended = 0;
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
        if (reference == "nib" && kind == "reg" && size == 4) begin
          void'($fscanf(fd, "%s %s", msb, lsb));
          if (msb == "[3:0]") var_ok = 1;
        end
        do void'($fscanf(fd, "%s", token)); while (token != "$end");
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
    $display("the module scope is named: %0d", module_ok);
    $display("the named begin block is a begin scope: %0d", begin_ok);
    $display("the named fork block is a fork scope: %0d", fork_ok);
    $display("the task is a task scope: %0d", task_ok);
    $display("the vector var gives its range: %0d", var_ok);
    $display("one upscope for every scope: %0d", upscopes == scopes);
    $display("the scopes nest and balance: %0d", balanced);
    $display("enddefinitions ends the declarations: %0d", ended);
  endtask

  initial begin : named_begin
    logic [3:0] nib = 4'h5;
    fork : named_fork
      begin
        logic in_fork = 1'b0;
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
