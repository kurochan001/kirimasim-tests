/*
:name: test_sched_nonblocking_target_index_at_execution
:description: The index of the target of a nonblocking assignment is evaluated when the assignment runs, not when the update is made (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 10.4.2 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nonblocking_target_index_at_execution.expected
*/
// IEEE 1800-2023 §10.4.2: when the target of a nonblocking assignment needs an
// evaluation, such as an index expression, it is evaluated at the same time as
// the right-hand side, when the statement runs. The index i changes to 1 before
// the NBA region (§4.4.2.4) makes the update, which still goes to element 0,
// with the value of y from when the statement ran.

module test_sched_nonblocking_target_index_at_execution;
  int a[2] = '{0, 0};
  int i = 0, y = 7;
  initial begin
    a[i] <= y;
    i = 1;
    y = 9;
    #1 $display("a[0]=%0d a[1]=%0d", a[0], a[1]);
  end
endmodule
