/*
:name: test_sched_strobe_after_zero_delays_and_nba
:description: $strobe prints the values at the end of the time step, after #0 resumptions, blocking writes made after them and the nonblocking update (IEEE 1800-2023 Section 4.4.2.9)
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.9 21.2.2 4.4.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sched_strobe_after_zero_delays_and_nba.expected
*/
// IEEE 1800-2023 §21.2.2: $strobe prints its arguments at the end of the time
// step, in the Postponed region (§4.4.2.9), when every event of the step has
// occurred. The process writes x after two #0 (§4.4.2.3) and then with a
// nonblocking assignment; the strobe made first sees the last value.
// The strobe of Verilator 5.052 prints the value from before the nonblocking
// update (docs/simulator-differences.md).

module test_sched_strobe_after_zero_delays_and_nba;
  int x = 0;
  initial begin
    x = 1;
    $strobe("strobe: x=%0d", x);
    #0 x = 2;
    #0 x <= 3;
    $display("display: x=%0d", x);
  end
endmodule
