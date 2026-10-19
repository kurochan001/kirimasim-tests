/*
:name: test_vpi_expression_operands
:description: An expression argument of a system task is a vpiOperation whose vpiOpType names the operator and whose vpiOperand iteration gives its operands in order, down to variables and constants, with the multiplier first for a replication (IEEE 1800-2023 Sections 36.10.3 and 37.59)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.10.3 37.59 36.4 11.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_expression_operands.c
:expected_stdout: @test_vpi_expression_operands.expected
*/
// IEEE 1800-2023 §36.10.3, §37.59: an expression with operands is a
// vpiOperation; vpiOpType gives the operator and vpi_iterate(vpiOperand) its
// operands, so the application can walk the whole expression. Precedence
// (11.3.2) decides the shape: in a + b * c the multiplication is an operand of
// the addition, and the parentheses of (a + b) * c make the addition an
// operand of the multiplication; no object stands for the parentheses. For a
// replication the first operand is the multiplier (37.59 detail 1). §36.4: the
// argument handles come from vpiArgument of the call. The application prints
// each tree with operator names and the names of the variables, the values of
// the constants, and the value of the whole argument.

module test_vpi_expression_operands;
  logic [3:0] a = 4'd5, b = 4'd2, c = 4'd3;
  logic s = 1'b1;

  initial begin
    $vt_tree(a + b * c);
    $vt_tree((a + b) * c);
    $vt_tree(a - (b - c));
    $vt_tree({a, b});
    $vt_tree({2{b}});
    $vt_tree(s ? -a : c);
  end
endmodule
