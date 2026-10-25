/*
:name: test_format_hierarchical_name_scopes
:description: %m takes no argument and prints the hierarchical name of the module instance, task, function, named block, labeled statement or generate block that calls the display task (IEEE 1800-2023 Section 21.2.1.5)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.5 9.3.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_hierarchical_name_scopes.expected
*/
// IEEE 1800-2023 §21.2.1.5: %m does not take an argument; it prints the
// hierarchical name of the design element, subroutine, named block or
// labeled statement in which the display task is called. §9.3.5: a label
// before begin names the block like a name after begin, so it adds a level
// to the name.
// The instance u1 prints %m from its initial procedure, from a task and a
// function it calls, from a block named after begin and from a block with a
// statement label; the top module prints it from its own initial procedure
// and from a generate block. The value after %m in the named block shows
// that %m leaves the argument to the next format. The lines are printed at
// different times, so their order is fixed.
// Icarus Verilog 13.0 rejects the statement label before begin.

module hier_name_sub;
  task show_task;
    $display("%m");
  endtask

  function void show_func();
    $display("%m");
  endfunction

  initial begin
    #1;
    $display("%m");
    show_task;
    show_func();
    begin : named_blk
      $display("%m %0d", 5);
    end
    lab: begin
      $display("[%m]");
    end
  end
endmodule

module test_format_hierarchical_name_scopes;
  hier_name_sub u1();

  if (1) begin : gen_blk
    initial #2 $display("%m");
  end

  initial $display("%m");
endmodule
