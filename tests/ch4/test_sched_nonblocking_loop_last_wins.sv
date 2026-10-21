/*
:name: test_sched_nonblocking_loop_last_wins
:description: Nonblocking assignments to one variable made in a loop update it in the order they ran, so the last one wins (IEEE 1800-2023 Section 4.4.2.4)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.4 10.4.2 12.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nonblocking_loop_last_wins.expected
*/
// IEEE 1800-2023 §10.4.2: the order in which distinct nonblocking assignments
// to a variable run is kept when they update it. A for loop (§12.7.1) makes
// four of them in one time step; after the NBA region (§4.4.2.4) x holds the
// value of the last.

module test_sched_nonblocking_loop_last_wins;
  int x = -1;
  initial begin
    for (int i = 0; i < 4; i++) x <= i * 10;
    $display("before the update: x=%0d", x);
    #1 $display("after the update: x=%0d", x);
  end
endmodule
