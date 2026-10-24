/*
:name: test_illegal_timing_condition_two_signals
:description: A timing check condition cannot combine two conditioning signals; they have to be combined into one signal outside the specify block, which can then condition the check (IEEE 1800-2023 Section 31.7)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the condition of the second $setup check combines the two conditioning signals en1 and en2
:expected_stderr_regex: test_illegal_timing_condition_two_signals\.sv:30:
*/
// IEEE 1800-2023 §31.7: if more than one conditioning signal is required for
// conditioning a timing check, the logic shall be combined into a separate
// signal outside the specify block, and that signal used as the condition.
// The cell combines en1 and en2 into both with a continuous assignment, and
// the first $setup is conditioned on both, which is legal. The second $setup
// combines en1 and en2 in its own condition.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design;
// neither of them performs timing checks.

`timescale 1ns/1ns

module tc2_cell(input wire clk, input wire d, input wire en1, input wire en2);
  wire both;
  assign both = en1 & en2;
  specify
    $setup(d, posedge clk &&& both, 3);
    $setup(d, posedge clk &&& (en1 && en2), 3);   // illegal: two conditioning signals
  endspecify
endmodule

module test_illegal_timing_condition_two_signals;
  logic clk = 1'b0, d = 1'b0, en1 = 1'b1, en2 = 1'b1;
  tc2_cell u (.clk(clk), .d(d), .en1(en1), .en2(en2));
  initial #1 $display("built");
endmodule
