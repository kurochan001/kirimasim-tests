/*
:name: test_sched_nba_chain_within_time_step
:description: Nonblocking updates that wake processes making further nonblocking assignments all settle within the same time step (IEEE 1800-2023 Section 4.5)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.5 4.4.2.4 4.4.2.9 21.2.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_nba_chain_within_time_step.expected
*/
// IEEE 1800-2023 §4.5: after the NBA region the scheduler goes back to the
// Active region while events remain, so an update that wakes a process making
// another nonblocking assignment is followed by that update in the same time
// step. a, b and c settle at time 0, as $strobe (§21.2.2, §4.4.2.9) shows; the
// display one unit later agrees.

module test_sched_nba_chain_within_time_step;
  int a = 0, b = 0, c = 0;
  always @(a) b <= a + 1;
  always @(b) c <= b + 1;
  initial begin
    #1;
    a <= 5;
    $strobe("strobe: a=%0d b=%0d c=%0d", a, b, c);
    #1 $display("display: a=%0d b=%0d c=%0d", a, b, c);
  end
endmodule
