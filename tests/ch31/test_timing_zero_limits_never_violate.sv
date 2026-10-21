/*
:name: test_timing_zero_limits_never_violate
:description: $removal with a limit of zero and $recrem with both limits zero never report a violation, even for events at the same time (IEEE 1800-2023 Section 31.3.4)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.4 31.3.6 31.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_zero_limits_never_violate.expected
*/
// IEEE 1800-2023 §31.3.4: when its limit is zero, $removal shall never issue
// a violation. §31.3.6: when both limits are zero, $recrem shall never issue a
// violation, although with positive limits it reports reference and data
// events that occur at the same time. The events below come together and 1
// apart in both orders, and neither notifier changes (31.6).
// Icarus Verilog 13.0 prints the same, but it skips timing checks
// (docs/simulator-differences.md), so its output does not show that it follows
// these rules.

`timescale 1ns/1ns

module timing_zero_limits(input clr, input clk);
  reg n1 = 0, n2 = 0;
  specify
    $removal(posedge clr, posedge clk, 0, n1);
    $recrem(posedge clr, posedge clk, 0, 0, n2);
  endspecify
endmodule

module test_timing_zero_limits_never_violate;
  reg clr = 0, clk = 0;

  timing_zero_limits u(clr, clk);

  always @(u.n1 or u.n2) $display("%0d: n1=%b n2=%b", $time, u.n1, u.n2);

  initial begin
    #10 clr = 1; clk = 1;
    #5 clr = 0; clk = 0;
    #5 clk = 1;
    #1 clr = 1;
    #5 clr = 0; clk = 0;
    #5 clr = 1;
    #1 clk = 1;
    #5 $display("end: n1=%b n2=%b", u.n1, u.n2);
  end
endmodule
