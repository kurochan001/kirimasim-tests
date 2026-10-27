/*
:name: test_A_extra_module_path
:description: A module path expression is a module path primary, a unary or binary module path expression with attribute instances, or a conditional one, and the module path primary is a number, an identifier, a concatenation, a function call or a parenthesized module path mintypmax expression (IEEE 1800-2023 Sections 30.4.4 and 11.2.1, A.8.3 and A.8.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4 11.2.1 A.7.2 A.8.3 A.8.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_module_path.expected
*/
// IEEE 1800-2023 A.8.3, module_path_expression: the forms are a
// module_path_primary, a unary_module_path_operator with attribute instances
// and a primary, two module path expressions with a binary module path
// operator and attribute instances, and a module path conditional expression
// with attribute instances after the question mark. A.8.4: a module path
// primary is a number, an identifier, a module path concatenation, a module
// path multiple concatenation, a function call or a parenthesized module path
// mintypmax expression. A.7.2 uses the expression as the condition of a
// state-dependent path declaration.
//
// One cell writes every form as the condition of a path declaration: the
// conditional with an attribute after ?, the binary expression with an
// attribute, the unary expression with an attribute, a parenthesized
// concatenation, the call f(sel), and the parenthesized mintypmax expression
// (1:2:3). The cell builds with each condition, and the test prints done.
// The 5.052 release of Verilator ignores module path delays but accepts the
// declarations.

`timescale 1ns/1ns
module mp_cell(input wire a, input wire sel, input wire en, output wire y);
  buf g (y, a);

  function automatic int f(input int x);
    return x;
  endfunction

  specify
    if (sel ?(* c1 *) en : 1) (a => y) = 1;
    if (sel &(* c2 *) en) (a => y) = 2;
    if (-(* c3 *) sel) (a => y) = 3;
    if ({sel, en}) (a => y) = 4;
    if (f(sel)) (a => y) = 5;
    if ((1:2:3)) (a => y) = 6;
  endspecify
endmodule

module test_A_extra_module_path;
  logic a = 0, sel = 0, en = 0;
  wire y;

  mp_cell u (.a(a), .sel(sel), .en(en), .y(y));

  initial begin
    #1 $display("done");
    $finish;
  end
endmodule
