/*
:name: test_illegal_clocking_inout_expression_not_lvalue
:description: the expression of a clocking inout has to be legal on a module output port too (IEEE 1800-2023 Section 14.5)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking inout io is associated with the expression a & b, which cannot be connected to an output port
:expected_stderr_regex: test_illegal_clocking_inout_expression_not_lvalue\.sv:27:
*/
// IEEE 1800-2023 §14.5: a clocking inout is a clocking input and a clocking
// output of the same signal, so its expression shall be legal both for a
// module input port and for a module output port. The inout v is associated
// with the variable select a[1:0], which is legal; the inout io is associated
// with a & b, which an input port could take but an output port cannot.
// Icarus Verilog 13.0 does not support clocking blocks, so the error it
// reports on this line does not count; Verilator 5.052 accepts the design.

module test_illegal_clocking_inout_expression_not_lvalue;
  logic clk = 0;
  logic [3:0] a, b;
  clocking cb @(posedge clk);
    inout v = a[1:0];
    inout io = a & b;   // illegal
  endclocking
endmodule
