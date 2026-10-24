/*
:name: test_illegal_hold_limit_negative
:description: The limit of a $hold timing check has to be nonnegative, so a negative constant limit is illegal, while a positive specparam limit is legal (IEEE 1800-2023 Section 31.3.2)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the $hold check on d2 has the negative limit -2
:expected_stderr_regex: test_illegal_hold_limit_negative\.sv:28:
*/
// IEEE 1800-2023 §31.3.2, Table 31-2: the limit of $hold is a nonnegative
// constant expression; negative limits are accepted only by $setuphold and
// $recrem, and only with the negative timing check option (31.9). The
// check on d1 uses the specparam tlim, 3, which is legal; the check on d2
// uses -2.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design;
// neither of them performs timing checks.

`timescale 1ns/1ns

module hon_cell(input wire clk, input wire d1, input wire d2);
  specify
    specparam tlim = 3;
    $hold(posedge clk, d1, tlim);
    $hold(posedge clk, d2, -2);   // illegal: negative limit
  endspecify
endmodule

module test_illegal_hold_limit_negative;
  logic clk = 1'b0, d1 = 1'b0, d2 = 1'b0;
  hon_cell u (.clk(clk), .d1(d1), .d2(d2));
  initial #1 $display("built");
endmodule
