/*
:name: test_illegal_timing_limit_from_net
:description: Timing check limits are constant expressions, which can use specparams, so a $width limit read from a net is illegal, while a limit computed from specparams is legal (IEEE 1800-2023 Section 31.2)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the limit of the second $width check is the net wlim
:expected_stderr_regex: test_illegal_timing_limit_from_net\.sv:30:
*/
// IEEE 1800-2023 §31.2: like the expressions of module path delays, timing
// check limit values are constant expressions, and they can include
// specparams. The first $width check uses the specparam expression tw * 2 + 1
// as its limit, which is legal; the second one uses the net wlim, which the
// cell drives from its input.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design;
// neither of them performs timing checks.

`timescale 1ns/1ns

module tln_cell(input wire clk, input wire [3:0] lim);
  wire [3:0] wlim;
  assign wlim = lim;
  specify
    specparam tw = 2;
    $width(posedge clk, tw * 2 + 1, 0);
    $width(negedge clk, wlim, 0);   // illegal: the limit is a net
  endspecify
endmodule

module test_illegal_timing_limit_from_net;
  logic clk = 1'b0;
  logic [3:0] lim = 4'd3;
  tln_cell u (.clk(clk), .lim(lim));
  initial #1 $display("built");
endmodule
