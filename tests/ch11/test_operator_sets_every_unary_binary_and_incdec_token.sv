/*
:name: test_operator_sets_every_unary_binary_and_incdec_token
:description: Each token of the unary, binary and increment or decrement operator sets is an operator with its own result: arithmetic, relational, logical and case and wildcard equality, logical connectives with implication and equivalence, bitwise, logical and arithmetic shifts, reductions, and pre and post increment and decrement (IEEE 1800-2023 Section 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3 11.4 11.4.2 11.4.5 11.4.6 11.4.7 11.4.10 A.8.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_sets_every_unary_binary_and_incdec_token.expected
*/
// IEEE 1800-2023 §11.3, Syntax 11-1 and A.8.6: the unary operators are
// + - ! ~ & ~& | ~| ^ ~^ ^~; the binary operators are + - * / % == != === !==
// ==? !=? && || ** < <= > >= & | ^ ^~ ~^ >> << >>> <<< -> <->; and the
// increment and decrement operators are ++ and --. Table 11-1 and §11.4 give
// each its meaning. The test applies every token to operands for which tokens
// that look alike give different results:
//   x = 17, y = 5; a = 8'hCA, b = 8'h53, c = 8'h07 (three 1 bits);
//   s = 8'shCA (-54) for the arithmetic shifts; l = 4'b10x1.
// §11.4.5: == and != give x when the x bit of l decides, === and !== compare
// x as a value. §11.4.6: ==? and !=? treat x, z and ? in the right operand as
// wildcards, but an x in the left one against a 0 gives x. §11.4.7: a -> b is
// !a || b, and a <-> b holds when both are true or both false. §11.4.10: >>>
// shifts in copies of the sign bit only for a signed left operand. §11.4.2:
// i++ and i-- give the old value, ++i and --i the new one. Results of the
// 8-bit operands print in hexadecimal.

module test_operator_sets_every_unary_binary_and_incdec_token;
  int x = 17, y = 5;
  logic [7:0] a = 8'hCA, b = 8'h53, c = 8'h07;
  logic signed [7:0] s = 8'shCA;
  logic [3:0] l = 4'b10x1;
  int i = 5, j, k, m, n;

  initial begin
    $display("arith %0d %0d %0d %0d %0d %0d", x + y, x - y, x * y, x / y, x % y, 2 ** y);
    $display("rel %0d %0d %0d %0d", x < y, x <= 17, x > y, x >= 18);
    $display("eq %b %b %b %b %b %b", x == 17, x != 17, l == 4'b10x1, l != 4'b10x1,
             l === 4'b10x1, l !== 4'b10x1);
    $display("wild %b %b %b %b %b", l ==? 4'b1?z1, l !=? 4'b1?z1, l ==? 4'b1001,
             4'b1001 ==? 4'b1x0x, 4'b1011 !=? 4'b1x0x);
    $display("logic %b %b %b %b %b %b %b %b %b", 2 && 0, 2 && 3, 0 || 0, 0 || 4, 1 -> 0,
             0 -> 0, 1 <-> 0, 0 <-> 0, 2 <-> 3);
    $display("bitwise %h %h %h %h %h", a & b, a | b, a ^ b, a ^~ b, a ~^ b);
    $display("shift %h %h %h %h %h", a >> 2, a << 2, a >>> 2, s >>> 2, s <<< 2);
    $display("unary %0d %0d %0d %0d %h %0d %0d %0d %0d %0d %0d %0d %0d %0d %0d", +x, -x, !x, !0,
             ~a, &a, &8'hFF, ~&a, |a, ~|a, ~|8'h00, ^c, ~^c, ^~c, ^a);
    j = i++;
    k = ++i;
    m = i--;
    n = --i;
    $display("incdec %0d %0d %0d %0d %0d", j, k, m, n, i);
  end
endmodule
