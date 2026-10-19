/*
:name: test_disable_enclosing_task
:description: A task that disables the task that called it ends both activations, and the caller of the outer task continues (IEEE 1800-2023 Section 9.6.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_disable_enclosing_task.expected
*/
// IEEE 1800-2023 §9.6.2: disabling a task ends its activity and everything
// it started, so when t_inner, called by t_outer, disables t_outer, the rest
// of t_inner and the rest of t_outer are skipped. Execution resumes after the
// statement that enabled t_outer.

module test_disable_enclosing_task;
  int c = 0;

  task automatic t_inner();
    c += 10;
    disable t_outer;
    c += 100;
  endtask

  task automatic t_outer();
    c += 1;
    t_inner();
    c += 1000;
  endtask

  initial begin
    t_outer();
    $display("after t_outer: c=%0d", c);
  end
endmodule
