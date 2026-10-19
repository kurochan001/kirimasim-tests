/*
:name: test_timing_width_period_notifier
:description: $width reports pulses narrower than the limit but wider than the threshold, and $period reports clock edges closer than the limit (IEEE 1800-2023 Section 31.4.4)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.4 31.4.5 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_width_period_notifier.expected
*/
// IEEE 1800-2023 §31.4.4: $width(posedge clk, 5, 1, nw) measures each high
// pulse from the rising to the falling edge and reports a violation when its
// width is greater than the threshold 1 and less than the limit 5; a pulse of
// width exactly 1 is not reported. §31.4.5: $period(posedge clk, 10, np) reports
// a violation when two rising edges are less than 10 apart. §31.6: each
// violation toggles the notifier, which starts at 0. The test prints the
// notifiers whenever they change.

`timescale 1ns/1ns

module timing_width_period(input clk);
  reg nw = 0, np = 0;
  specify
    $width(posedge clk, 5, 1, nw);
    $period(posedge clk, 10, np);
  endspecify
endmodule

module test_timing_width_period_notifier;
  reg clk = 0;

  timing_width_period u(clk);

  always @(u.nw or u.np) $display("%0d: width notifier=%b period notifier=%b", $time, u.nw, u.np);

  initial begin
    #10 clk = 1;    // 10
    #6 clk = 0;     // 16: width 6
    #4 clk = 1;     // 20: period 10
    #3 clk = 0;     // 23: width 3: violation
    #3 clk = 1;     // 26: period 6: violation
    #6 clk = 0;     // 32: width 6
    #8 clk = 1;     // 40: period 14
    #1 clk = 0;     // 41: width 1, equal to the threshold: not reported
    #9 clk = 1;     // 50: period 10
    #6 clk = 0;     // 56
    #10 $finish;
  end
endmodule
