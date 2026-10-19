/*
:name: test_nba_intra_assignment_event_control
:description: A nonblocking assignment with an intra-assignment event control returns at once and assigns the value of its right-hand side from when it ran (IEEE 1800-2023 Section 10.4.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.2 9.4.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_intra_assignment_event_control.expected
*/
// IEEE 1800-2023 §10.4.2: a nonblocking assignment does not block the
// process, also when it has an intra-assignment event control (9.4.5):
// "a <= @(posedge clk) b" evaluates b at once, schedules the update of a for
// the next posedge of clk, and the process continues with the next statement
// in the same time step. A later change of b does not change the value
// assigned.

module test_nba_intra_assignment_event_control;
  int a, b;
  bit clk = 0;

  always #10 clk = ~clk;

  initial begin
    b = 3;
    a <= @(posedge clk) b;
    $display("t=%0d the assignment returned", $time);
    b = 4;
  end

  initial begin
    #9 $display("t=%0d a=%0d", $time, a);
    #2 $display("t=%0d a=%0d", $time, a);
    $finish;
  end
endmodule
