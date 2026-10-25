/*
:name: test_let_expression_constant_and_runtime
:description: A let declaration substitutes its actual arguments for its formal ports; with constant arguments and a right-hand side that is a constant expression when the formals are constant primaries, the let expression is a constant primary that gives a local parameter, and elsewhere it is a primary whose value follows the arguments (IEEE 1800-2023 Section 11.12 and footnote 50 of A.10)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 11.2.1 A.9.3 A.8.4 A.8.3 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_let_expression_constant_and_runtime.expected
*/
// IEEE 1800-2023 A.8.4: a constant let expression is a constant primary, and
// a let expression is a primary. A.8.3: the arguments of a let expression are
// constant expressions where it is a constant primary. Footnote 50 of A.10:
// in a constant let expression all arguments are constant expressions and the
// right-hand side is one too, with the formal arguments treated as constant
// primaries there. A formal of a let declaration is a formal port, which is
// also a constant primary (A.8.4).
//
// §11.12: the let declaration maxc(a, b) = (a > b) ? a : b; substitutes its
// arguments, so maxc(3, 7) is 7, maxc(9, 2) is 9 and maxc(4, 4) is 4. With
// x = 15 and y = 6 at run time, maxc(x, y) is 15, maxc(y, x) is 15 and
// maxc(x - 9, y + 4) is maxc(6, 10) = 10.
//
// Icarus Verilog 13.0 does not support let declarations; this expected output
// comes from the standard and Verilator 5.052 produces it.

module test_let_expression_constant_and_runtime;
  let maxc(a, b) = (a > b) ? a : b;
  localparam int LET1 = maxc(3, 7);
  localparam int LET2 = maxc(9, 2);
  localparam int LET3 = maxc(4, 4);
  int x = 15, y = 6, r;

  initial begin
    r = maxc(x, y);
    $display("const %0d %0d %0d", LET1, LET2, LET3);
    $display("runtime %0d %0d %0d", r, maxc(y, x), maxc(x - 9, y + 4));
  end
endmodule
