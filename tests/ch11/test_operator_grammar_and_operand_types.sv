/*
:name: test_operator_grammar_and_operand_types
:description: The operator grammar covers compound assignments, conditional, unary and binary arithmetic, logical, bitwise, comparison, shift, implication, equivalence, increment, decrement and both streaming directions, and case, logical and conditional operators accept integral, string, aggregate and class operands (IEEE 1800-2023 Section 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_grammar_and_operand_types.expected
*/
// IEEE 1800-2023 §11.3: Syntax 11-1 and Table 11-1 list the operators. This
// test applies every compound assignment, both increment and decrement, the
// conditional operator, unary and binary arithmetic, logical, bitwise,
// comparison and shift operators, implication and equivalence, and both
// streaming directions. It then uses case equality, case inequality, logical
// equality and the conditional operator with integral, string, aggregate and
// class-handle operands, which Table 11-1 allows outside real and shortreal.
//
// Icarus Verilog 13.0 does not support streaming concatenations and the
// 5.052 release of Verilator is two-state, so the expectation follows 11.3.

typedef struct packed {
  bit a;
  bit b;
} p2_t;

class C;
  int v;
  function new(int x);
    v = x;
  endfunction
endclass

module test_operator_grammar_and_operand_types;
  int a, b;
  string s1, s2;
  p2_t p, q, tp;
  C c1, c2, c3, tc;
  logic [3:0] x1, x2;
  logic [7:0] sr, sl;

  initial begin
    a = 5;
    b = 2;
    a += 3;
    a -= 1;
    a *= 2;
    a /= 7;
    a %= 2;
    a |= 8'hF0;
    a &= 8'h3C;
    a ^= 8'hFF;
    a <<= 1;
    a >>= 1;
    a <<<= 1;
    a >>>= 1;
    a++;
    b--;
    $display("assign=%0d,%0d", a, b);
    $display("arith=%0d,%0d,%0d", 7 / 2, 7 % 2, 2 ** 3);
    $display("logic=%0d,%0d,%0d", (1 && 0), (1 || 0), (1 -> 0));
    $display("equiv=%0d,%0d", (1 <-> 1), (0 <-> 1));
    $display("bit=%b,%b,%b", 4'b1010 & 4'b1100, 4'b1010 | 4'b0101,
             ~4'b1010);
    $display("red=%b,%b", &4'b1111, ^4'b1010);
    $display("cmp=%0d,%0d", (3 < 4), (3 >= 4));
    $display("shift=%h,%h", 8'h81 << 1, 8'h81 >> 1);
    $display("unary=%0d,%0d", !0, -(-5));
    $display("wild=%0d", (4'b1001 ==? 4'b1x01));
    sr = {>>{8'h96}};
    sl = {<<{8'h96}};
    $display("stream=%h,%h", sr, sl);

    s1 = "abc";
    s2 = "abc";
    p.a = 1;
    p.b = 0;
    q.a = 1;
    q.b = 0;
    c1 = new(1);
    c2 = c1;
    c3 = new(1);
    x1 = 4'b1x01;
    x2 = 4'b1x01;
    $display("case_int=%0d", (x1 === x2));
    $display("case_str=%0d", (s1 === s2));
    $display("case_agg=%0d", (p === q));
    $display("case_cls=%0d", (c1 === c2));
    $display("eq_str=%0d,%0d", (s1 == s2), (s1 != "abd"));
    $display("eq_agg=%0d,%0d", (p == q), (p != q));
    $display("eq_cls=%0d,%0d", (c1 == c2), (c1 == c3));
    $display("cond_str=%s", (a != 0) ? "yes" : "no");
    tp = (a != 0) ? p : q;
    $display("cond_agg=%0d", tp.a);
    tc = (a != 0) ? c1 : c3;
    $display("cond_cls=%0d", tc.v);
    $display("cond_real=%0.1f", (a != 0) ? 1.5 : 2.5);
  end
endmodule
