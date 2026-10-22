/*
:name: test_precedence_distinguishing_values
:description: Distinguish precedence and associativity using unequal alternative results
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_precedence_distinguishing_values.expected
*/
// IEEE 11.3.2 and 11.4.3: each unparenthesized result differs from
// the explicitly grouped alternative. Shared precedence and left grouping
// of / % * are checked together; ?: and ->/<-> group to the right.
module test_precedence_distinguishing_values;
  int a = 1, b = 0, c = 0;
  int x = 10, y = 3, z = 1;
  logic [3:0] p = 4'h2, q = 4'h3;
  initial begin
    $display("logical=%0d grouped=%0d", a || b && c, (a || b) && c);
    $display("unary=%0d grouped=%0d", -y + x, -(y + x));
    $display("compare=%0d grouped=%0d", p & q == p, (p & q) == p);
    $display("additive=%0d grouped=%0d", x - y + z, x - (y + z));
    $display("multiplicative=%0d grouped=%0d", 24 / y % 5 * 2, 24 / (y % (5 * 2)));
    $display("conditional=%0d grouped=%0d", a ? b : a ? 2 : 3, (a ? b : a) ? 2 : 3);
    $display("implication=%0d grouped=%0d", b -> a -> b, (b -> a) -> b);
    $display("mixed=%0d grouped=%0d", b -> a <-> b, (b -> a) <-> b);
    $display("conditional_before_implies=%0d grouped=%0d",
             a ? b : a -> b, a ? b : (a -> b));
    $finish;
  end
endmodule
