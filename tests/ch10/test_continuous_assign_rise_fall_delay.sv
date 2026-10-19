/*
:name: test_continuous_assign_rise_fall_delay
:description: A continuous assignment to a scalar net with two delays uses the first for a rising and the second for a falling output, and a change that reverts before its delay has passed never reaches the net (IEEE 1800-2023 Sections 10.3.3 and 28.16)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3 28.16
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_continuous_assign_rise_fall_delay.expected
*/
// IEEE 1800-2023 §10.3.3: for a scalar net the delays of a continuous
// assignment are treated as gate delays (28.16), so o rises 2 and falls 6 after
// i changes. When the right-hand side changes again before an earlier change
// has propagated, the scheduled change is removed, and if the new value equals
// the net's current value nothing is scheduled: the pulses of i from 30 to 31
// and of j from 41 to 43 are shorter than the delays and never reach o or p.
// The outputs settle from x at the start, which the procedures do not print.

`timescale 1ns/1ns

module test_continuous_assign_rise_fall_delay;
  logic i = 0, j = 0;
  wire o, p;

  assign #(2, 6) o = i;
  assign #4 p = j;

  always @(o) if ($time >= 10) $display("%0d: o = %b", $time, o);
  always @(p) if ($time >= 10) $display("%0d: p = %b", $time, p);

  initial begin
    #10 i = 1;
    #10 i = 0;
    #10 i = 1;
    #1 i = 0;
    #10 j = 1;
    #2 j = 0;
    #10 j = 1;
    #10 $finish;
  end
endmodule
