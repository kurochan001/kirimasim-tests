/*
:name: test_syntax_let_declaration_and_argument_forms
:description: let declarations without parentheses, with empty parentheses and with ports and defaults, called through a package scope and with omitted, positional, named and mixed actual arguments (IEEE 1800-2023 Section 11.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.12 A.2.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_let_declaration_and_argument_forms.expected
*/
// IEEE 1800-2023 A.2.12: a let declaration is let, a name, optional
// parentheses with an optional port list, = an expression and a semicolon.
// A let expression is the name, optionally after a package scope, with
// optional parentheses holding optional arguments: positional actuals, any
// of which may be left empty, optionally followed by named actuals
// .name(actual), or named actuals alone. §11.12: the body is expanded with
// the actuals in place of the formals, a formal with a default takes the
// default when its actual is omitted, and the expansion is enclosed in
// parentheses, so 2 * twice(...) doubles the whole sum.
//
// sum_ab has no parentheses and diff_ab empty ones; pick has defaults 3 and
// 2 for y and z and is called with every argument form; lp::sq is reached
// through its package.
// Icarus Verilog 13.0 rejects the let declaration in the package (syntax
// error).

package lp;
  let sq(x) = x * x;
endpackage

module test_syntax_let_declaration_and_argument_forms;
  int a = 5, b = 3;

  let sum_ab = a + b;
  let diff_ab() = a - b;
  let pick(x, y = 3, z = 2) = x + y * z;
  let twice(w) = w + w;
  let inc(untyped q) = q + 1;

  initial begin
    $display("sum_ab=%0d diff_ab=%0d", sum_ab, diff_ab());
    $display("all=%0d skip_y=%0d only_x=%0d", pick(a, 1, 4), pick(a, , 3), pick(a));
    $display("pos_named=%0d skip_named=%0d", pick(a, .z(4)), pick(a, , .z(5)));
    $display("named_zx=%0d named_yx=%0d", pick(.z(1), .x(7)), pick(.y(10), .x(1)));
    $display("sq=%0d twice=%0d inc=%0d", lp::sq(a), 2 * twice(b + 1), inc(4));
  end
endmodule
