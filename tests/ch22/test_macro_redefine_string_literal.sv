/*
:name: test_macro_redefine_string_literal
:description: Macro redefinition in mid-file, no expansion inside string literals, and macro names without a backtick
:tags: ch22
:type: simulation
:lrm: 1800-2023 22.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_macro_redefine_string_literal.expected
*/
`timescale 1ns/1ps
// A macro redefined in the middle of a file applies only to the text after the
// new definition, macros are not expanded inside string literals, and an
// identifier without a backtick is not a macro use (22.5.1).
`define V 1
`define dbl(x) ((x)*2)
module top;
  int a = `V;
`define V 2
  int b = `V;
  int y; string s;
  function int dbl(int x); return x + 1; endfunction
  initial begin
    s = "value: `V here";
    y = dbl(3);
    if (a !== 1 || b !== 2) $fatal(1, "mid-file redefinition: a=%0d b=%0d exp 1,2", a, b);
    if (s.len() != 14) $fatal(1, "string-literal expansion: '%s' len=%0d exp 14", s, s.len());
    if (y !== 4) $fatal(1, "backtick-less expansion: dbl(3)=%0d exp 4", y);
    $display("ALL CHECKS OK"); $finish;
  end
endmodule
