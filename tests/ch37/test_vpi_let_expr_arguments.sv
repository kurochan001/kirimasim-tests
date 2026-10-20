/*
:name: test_vpi_let_expr_arguments
:description: A let expression gives its declaration and, through vpiArgument, its arguments in the order of the formals, with the default value of a formal that the call leaves out (IEEE 1800-2023 Section 37.57)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.57 11.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_let_expr_arguments.c
:expected_stdout: @test_vpi_let_expr_arguments.expected
*/
// IEEE 1800-2023 §37.57: vpiArgument of a let expression returns its arguments
// in the order the formals of the let are declared, and the default value of a
// formal that the call does not give; the let expression also leads to its
// declaration. scaled (11.12) has the formals x and k, k with the default 3;
// the continuous assignment calls it with a only, so the arguments are a, which
// is 5, and 3.

`timescale 1ns/1ns

module test_vpi_let_expr_arguments;
  int a = 5, y;

  let scaled(x, k = 3) = x * k;

  assign y = scaled(a);

  initial #1 $vt_let;
endmodule
