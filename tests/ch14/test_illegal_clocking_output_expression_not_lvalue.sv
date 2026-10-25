/*
:name: test_illegal_clocking_output_expression_not_lvalue
:description: the expression of a clocking output has to be legal on a module output port (IEEE 1800-2023 Section 14.5)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking output o is associated with the expression a + b, which cannot be connected to an output port
:expected_stderr_regex: test_illegal_clocking_output_expression_not_lvalue\.sv:27:
*/
// IEEE 1800-2023 §14.5: an expression associated with a clocking output or
// inout signal shall be legal for connection to a module output port, which
// takes a net or variable, a select of one, or a concatenation of them. The
// output p is associated with the concatenation {a, b}, which is legal; the
// output o is associated with a + b.
// Icarus Verilog 13.0 does not support clocking blocks, so the error it
// reports on this line does not count; Verilator 5.052 accepts the design.

module test_illegal_clocking_output_expression_not_lvalue;
  logic clk = 0;
  logic [3:0] a, b;
  clocking cb @(posedge clk);
    output p = {a, b};
    output o = a + b;   // illegal
  endclocking
endmodule
