/*
:name: test_vpi_expression_typespec
:description: A cast expression, a simple expression, a data-type-prefixed assignment pattern and a data-type-prefixed multiple-assignment pattern each have a typespec, the cast of a typedef name gives that name, and the pattern operation types are the assignment and multiple-assignment pattern kinds (IEEE 1800-2023 Section 37.59)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.59 11.4.14 10.9 7.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_expression_typespec.c
:expected_stdout: @test_vpi_expression_typespec.expected
*/
// IEEE 1800-2023 §37.59 detail 5: the one-to-one relation to a typespec is
// always available for a vpiCastOp operation, for a simple expression, and
// for a vpiAssignmentPatternOp or vpiMultiAssignmentPatternOp whose curly
// braces are prefixed by a data type name. detail 3: a cast is a unary
// operation whose typespec is the target type. detail 6: the operands of an
// assignment pattern are the expressions in positional notation, and detail 7
// makes the first operand of a multiple-assignment pattern its multiplier.
// The task exprs is never called, but its statements are source objects
// (37.3.7), so the application reads each assignment's right-hand side: a
// cast from int, a simple variable expression, a cast from the typedef nib_t
// (37.25 detail 1 gives its name), an int-prefixed assignment pattern and an
// int-prefixed multiple-assignment pattern. The lines are sorted by the
// name of the assigned variable, because the order of the statements is not
// what the standard fixes here.

module test_vpi_expression_typespec;
  int a1, a2, b;
  typedef logic [3:0] nib_t;
  nib_t n1;
  typedef struct { int x; int y; } pair_t;
  pair_t p1, p2;

  task exprs;
    a1 = int'(b);
    a2 = b;
    n1 = nib_t'(b);
    p1 = pair_t'{1, 2};
    p2 = pair_t'{2{1}};
  endtask

  initial #1 $vt_types;
endmodule
