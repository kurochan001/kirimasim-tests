/*
:name: test_illegal_clocking_input_expression_with_assignment
:description: the expression of a clocking input has to be legal on a module input port, which excludes an assignment operator (IEEE 1800-2023 Section 14.5)
:tags: ch14
:type: elaboration
:lrm: 1800-2023 14.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the clocking input i2 is associated with the expression (a = b), which contains an assignment operator
:expected_stderr_regex: test_illegal_clocking_input_expression_with_assignment\.sv:30:
*/
// IEEE 1800-2023 §14.5: an expression associated with a clocking input or
// inout signal shall be legal for connection to a module input port. An
// input port takes any expression, but an expression outside a procedural
// statement, such as a port connection, shall not contain an assignment
// operator (11.3.6). The input i1 is associated with a & b, and the input i3
// with the select a[1:0]; the input i2 is associated with (a = b).
// Icarus Verilog 13.0 does not support clocking blocks, so the error it
// reports on this line does not count; Verilator 5.052 accepts the design
// with a warning.

module test_illegal_clocking_input_expression_with_assignment;
  logic clk = 0;
  logic [3:0] a, b;
  clocking cb @(posedge clk);
    input i1 = a & b;
    input i3 = a[1:0];
    input i2 = (a = b);   // illegal
  endclocking
endmodule
