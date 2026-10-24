/*
:name: test_illegal_setup_limit_not_constant
:description: The limit of a $setup timing check has to be a constant expression, so a limit read from a variable is illegal, while a specparam limit is legal (IEEE 1800-2023 Section 31.3.1)
:tags: ch31
:type: elaboration
:lrm: 1800-2023 31.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the limit of the $setup check on d2 is the variable lim
:expected_stderr_regex: test_illegal_setup_limit_not_constant\.sv:28:
*/
// IEEE 1800-2023 §31.3.1, Table 31-1: the limit of $setup is a nonnegative
// constant expression, which can use specparams (31.2). The check on d1
// uses the specparam tlim, which is legal; the check on d2 uses the
// variable lim, which has a value only during simulation.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design;
// neither of them performs timing checks.

`timescale 1ns/1ns

module sev_cell(input wire clk, input wire d1, input wire d2);
  logic [3:0] lim = 4'd2;
  specify
    specparam tlim = 3;
    $setup(d1, posedge clk, tlim);
    $setup(d2, posedge clk, lim);   // illegal: the limit is a variable
  endspecify
endmodule

module test_illegal_setup_limit_not_constant;
  logic clk = 1'b0, d1 = 1'b0, d2 = 1'b0;
  sev_cell u (.clk(clk), .d1(d1), .d2(d2));
  initial #1 $display("built");
endmodule
