/*
:name: test_clocking_zero_skew_input_not_resampled
:description: an input with an explicit #0 skew is sampled in the Observed region of the clocking event and is not sampled again when the Reactive region makes the time step run its Active and Observed regions once more without a new clocking event (IEEE 1800-2023 Section 14.13)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.13 14.4 24.3 4.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_zero_skew_input_not_resampled.expected
*/
// IEEE 1800-2023 §14.13, §14.4: an input with an explicit #0 skew samples its
// signal in the Observed region of the time step of the clocking event. If
// processing the Reactive region creates Active events, so that the Observed
// region runs again in the same time step, such an input is not sampled
// again unless a new clocking event occurs. §24.3, §4.4.2: a program process
// resumes in the Reactive region, after the Observed region.
//
// clk rises at 5. The nonblocking assignment d <= 1 at that edge updates d
// before the Observed region, so cb.d takes 1. The program, resumed by the
// same edge in the Reactive region, then sets d to 2; the always procedure
// that counts the changes of d runs in a new Active region, and the Observed
// region follows it again, with no new edge of clk. At 6 cb.d still holds 1,
// while d is 2 and has changed twice. A simulator that samples #0 inputs in
// every Observed region prints cb.d=2, and one that samples before the
// nonblocking assignment prints cb.d=0.
// Icarus Verilog 13.0 does not support clocking blocks. In the 5.052 release
// of Verilator the program process runs in the Active region of the edge,
// before the nonblocking assignment, and d=1 is printed.

`timescale 1ns/1ns

program p_rewrite(input logic clk);
  initial begin
    @(posedge clk);
    test_clocking_zero_skew_input_not_resampled.d = 2;
    #2;
  end
endprogram

module test_clocking_zero_skew_input_not_resampled;
  logic clk = 0;
  int d = 0;
  int changes = 0;

  clocking cb @(posedge clk);
    input #0 d;
  endclocking

  always @(posedge clk) d <= 1;
  always @(d) if ($time > 0) changes++;

  p_rewrite p(clk);

  initial #5 clk = 1;

  initial #6 $display("t=%0t cb.d=%0d d=%0d changes of d=%0d", $time, cb.d, d, changes);
endmodule
