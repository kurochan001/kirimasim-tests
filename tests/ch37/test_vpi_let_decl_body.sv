/*
:name: test_vpi_let_decl_body
:description: A let declaration iterates its body expression with vpiExpr; it is reached from a let expression that instantiates it (IEEE 1800-2023 Section 37.57)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.57 11.12 37.47
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_let_decl_body.c
:expected_stdout: @test_vpi_let_decl_body.expected
*/
// IEEE 1800-2023 §37.57: a let expression leads to the let declaration it
// instantiates (vpiLetDecl), which has vpiName and iterates, with vpiExpr, the
// expression of its body; §11.12: the body is the expression after = in the
// declaration, written in terms of the formals. The let declarations scaled
// and both have the bodies x * k and p && q; the continuous assignments to y1
// and y2 (37.47) instantiate them. From a start-of-simulation callback the
// application takes the right-hand side of each continuous assignment, its let
// declaration, and prints the name of the declaration and every expression of
// its vpiExpr iteration, an operation as its operands around its operator.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiLetExpr and vpiLetDecl, and a run
// with Verilator 5.052 iterates no continuous assignments.

module test_vpi_let_decl_body;
  int a, b, y1, y2;

  let scaled(x, k = 3) = x * k;
  let both(p, q) = p && q;

  assign y1 = scaled(a);
  assign y2 = both(a, b);
endmodule
