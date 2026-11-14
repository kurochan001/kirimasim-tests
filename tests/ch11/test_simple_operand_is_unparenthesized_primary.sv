/*
:name: test_simple_operand_is_unparenthesized_primary
:description: only an unparenthesized primary is a simple operand, where the propagated width and sign are applied; a parenthesized or compound operand passes them on to its own operands (IEEE 1800-2023 Section 11.5)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5 11.8.2
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_simple_operand_is_unparenthesized_primary.expected
*/
// IEEE 1800-2023 §11.5: an operand is simple when it is a primary (A.8.4)
// and not parenthesized: an identifier, a select, a concatenation or a
// function call is one, while a compound expression is not, nor is a
// parenthesized expression, although a parenthesized expression is a
// primary. §11.8.2: the type and width of an expression are propagated down
// to its context-determined operands until a simple operand is reached, and
// that operand is converted, sign-extended only when the propagated type is
// signed.
// a + b, with a = 4'hf and b = 4'h1, is evaluated with 8 bits inside the
// 8-bit assignment, both with and without parentheses, because neither form
// is a simple operand: the sum is 16 and shifting it right by one gives 8.
// A function call returning the 4-bit sum and a concatenation of the sum are
// simple operands, so their 4-bit value 0 is what is extended. The
// part-selects w[3:0] are simple operands extended before the addition, so
// 15 + 15 is 30. With sp = 4'sd7 in a signed 8-bit context, (sp + sp) is 14,
// while the signed 4-bit function result 7 + 7 wraps to -2 and is then
// sign-extended. A tool that treated a parenthesized expression as a simple
// operand would print 00 on the first line and -2 for (sp + sp).

module test_simple_operand_is_unparenthesized_primary;
  logic [3:0] a = 4'hf, b = 4'h1;
  logic [7:0] w = 8'h0f;
  logic signed [3:0] sp = 4'sd7;
  logic [7:0] r1, r2, r3, r4, r5;
  logic signed [7:0] s1, s2;

  function automatic logic [3:0] add4(logic [3:0] x, logic [3:0] y);
    return x + y;
  endfunction

  function automatic logic signed [3:0] add4s(logic signed [3:0] x, logic signed [3:0] y);
    return x + y;
  endfunction

  initial begin
    r1 = (a + b) >> 1;
    r2 = a + b >> 1;
    r3 = add4(a, b) >> 1;
    r4 = {a + b} >> 1;
    r5 = w[3:0] + w[3:0];
    $display("parenthesized %h, compound %h, call %h, concatenation %h, select %h", r1, r2,
             r3, r4, r5);
    s1 = (sp + sp) + 8'sd0;
    s2 = add4s(sp, sp) + 8'sd0;
    $display("signed: parenthesized %0d, call %0d", s1, s2);
  end
endmodule
