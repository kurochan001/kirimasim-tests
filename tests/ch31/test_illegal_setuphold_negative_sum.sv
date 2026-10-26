/*
:name: test_illegal_setuphold_negative_sum
:description: the setuphold limits add up to less than one precision unit (IEEE 1800-2023 Section 31.3.3)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $setuphold has the limits -5 ns and 2 ns, whose sum -3 ns is not above 1 ns
:expected_stderr_regex: test_illegal_setuphold_negative_sum\.sv:22:
*/
// When either limit of $setuphold is negative, the setup limit plus the
// hold limit shall exceed one simulation unit of precision. With the
// precision 1 ns here, -5 ns + 2 ns does not.

`timescale 1ns/1ns

module tcell(input logic clk, input logic d);
  specify
    $setuphold(posedge clk, d, -5, 2);   // illegal: sum is -3 ns
  endspecify
endmodule

module test_illegal_setuphold_negative_sum;
  logic clk = 1'b0, d = 1'b0;
  tcell u(.clk(clk), .d(d));
  initial #1 $display("built");
endmodule
