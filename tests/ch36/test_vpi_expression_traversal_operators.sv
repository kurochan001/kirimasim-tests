/*
:name: test_vpi_expression_traversal_operators
:description: A recursive walk over vpiOperation objects and their vpiOperand iterations reaches every operand of logical, bitwise, shift, relational, power, modulus and reduction operators, nested by precedence, and an omitted argument is a vpiNullOp operation without an operand iterator (IEEE 1800-2023 Section 36.10.3)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.10.3 37.59 37.42 11.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_expression_traversal_operators.c
:expected_stdout: @test_vpi_expression_traversal_operators.expected
*/
// IEEE 1800-2023 §36.10.3: VPI gives access to any expression of the source;
// one with operands is a vpiOperation, whose vpiOpType tells the operator and
// so the number of operands, and an application walks the whole expression
// by iterating vpiOperand recursively. An operation is evaluated after its
// operands, so the operator that binds least is at the root, and the
// precedence of 11.3.2 decides the shape: ! over &&, which binds more than
// ||; a shift over & over |; relational operators over ==; ** over %. The
// walk of 36.10.3 meets no operand iterator for an operation of type
// vpiNullOp, which is what an omitted argument is (37.42 detail 8). $vt_tree
// prints each argument as a tree, with the names of variables and the values
// of constants, then the value of the argument.

module test_vpi_expression_traversal_operators;
  logic [3:0] a = 4'd2, b = 4'd3, c = 4'd5;

  initial begin
    $vt_tree(!a && b || c);
    $vt_tree(a << 1 | b & c);
    $vt_tree(a < b == c > b);
    $vt_tree(b ** a % c);
    $vt_tree(~&a ^ &c);
    $vt_tree(a, , b);
  end
endmodule
