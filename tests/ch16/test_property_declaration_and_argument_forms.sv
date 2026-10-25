/*
:name: test_property_declaration_and_argument_forms
:description: A property declaration may have no port list or typed ports with a default and a local input, an assertion variable declaration and an optional semicolon; its instance may be bare, with empty parentheses, with positional, named or omitted arguments, and a property formal may take a sequence actual (IEEE 1800-2023 Sections 16.8 and 16.12.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.12.1 16.14.1 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_declaration_and_argument_forms.expected
*/
// IEEE 1800-2023 §16.12.1 with A.2.10: a property declaration has a name, an
// optional port list, a body and endproperty with an optional label; its body
// may hold assertion variable declarations, and the semicolon before
// endproperty is optional. A property instance may leave out the parentheses
// or write empty ones, and its actual arguments may be positional, named, or
// left out when the formal has a default (§16.8). A formal declared with the
// keyword property takes a property or sequence actual. A let declaration is
// an assertion item declaration too.
//
// p_simple has no ports and no semicolon before its end label, and its body
// uses the let both. p_args has a typed input with a default, a local input
// with a default, and an assertion variable declaration. p_prop takes a
// property formal and a typed input. The six instances differ only in how
// their arguments are written, so the first five fail once, at the second
// tick where a is 1 and b is 0, except the one that leaves y at its default 1
// and never fails; p_prop, whose sequence actual is a ##1 b, fails at the
// last three ticks.

`timescale 1ns/1ns

module test_property_declaration_and_argument_forms;
  logic clk = 0, a = 0, b = 0;
  int f_simple = 0, f_rep = 0, f_pos = 0, f_named = 0, f_omit = 0, f_prop = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  let both = a && b;

  sequence s_ab;
    a ##1 b;
  endsequence : s_ab

  property p_simple;
    a |-> both
  endproperty : p_simple

  property p_args(logic x, logic y = 1'b1, local input int n = 1);
    int cnt;
    (x |-> y) and (n >= 1);
  endproperty : p_args

  property p_prop(property inner, logic v);
    inner and v;
  endproperty

  a1: assert property (@(posedge clk) p_simple) else f_simple++;
  a2: assert property (@(posedge clk) p_simple()) else f_rep++;
  a3: assert property (@(posedge clk) p_args(a, b)) else f_pos++;
  a4: assert property (@(posedge clk) p_args(a, .y(b), .n(2))) else f_named++;
  a5: assert property (@(posedge clk) p_args(a, , 2)) else f_omit++;
  a6: assert property (@(posedge clk) p_prop(s_ab, 1'b1)) else f_prop++;

  initial begin
    a = 0;
    b = 0;
    #3 a = 1; b = 1;
    #10 a = 1; b = 0;
    #10 a = 0; b = 1;
    #10 a = 0; b = 0;
    #5 $display("simple %0d, empty %0d, positional %0d, named %0d, omitted %0d, property %0d",
                f_simple, f_rep, f_pos, f_named, f_omit, f_prop);
    $finish;
  end
endmodule
