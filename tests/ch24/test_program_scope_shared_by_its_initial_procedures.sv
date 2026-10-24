/*
:name: test_program_scope_shared_by_its_initial_procedures
:description: A program is a scope whose data, tasks and functions are shared by all of its initial procedures, each of which starts the testbench code (IEEE 1800-2023 Section 24.2)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_scope_shared_by_its_initial_procedures.expected
*/
// IEEE 1800-2023 §24.2: a program provides an entry point to the execution of
// a testbench and creates a scope that encapsulates program-wide data, tasks
// and functions. psh_tb declares total, the task add and the function twice.
// Its first initial procedure adds 3 at 1; its second one adds twice(5) at 2
// and prints total, which includes the first addition. Two instances of the
// program have scopes of their own, so the second one, which adds only in its
// second procedure because its parameter skips the first, ends with another
// total.

`timescale 1ns/1ns

program psh_tb #(parameter bit FIRST = 1'b1);
  int total = 0;
  task automatic add(int v);
    total += v;
  endtask
  function automatic int twice(int v);
    return 2 * v;
  endfunction
  initial if (FIRST) #1 add(3);
  initial begin
    #2 add(twice(5));
    #(FIRST ? 1 : 2) $display("%m total=%0d", total);
  end
endprogram

module test_program_scope_shared_by_its_initial_procedures;
  psh_tb #(1'b1) p1 ();
  psh_tb #(1'b0) p2 ();
endmodule
