/*
:name: test_expr_precedence_associativity
:description: the operator table groups and associates as listed, conditional groups right, and assignment forms bind looser than arithmetic (IEEE 1800-2023 11.3.2, 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_expr_precedence_associativity.expected
*/
// IEEE 1800-2023 §11.3.2: operators on one row of Table 11-2 have equal
// precedence, rows above bind tighter, all associate left except the
// conditional, implication and equivalence operators, which associate right.
// §11.3 and §11.11: the assignment forms include compound assignment, which
// has the loosest precedence above concatenation. Each printed value changes
// if the grouping or the precedence of one pair of operators is wrong:
// 20-5-3 is 12 only when the subtraction is left grouping, 2**3**2 is 64 only
// when the power is left grouping, 1?0:1?2:3 is 0 only when the conditional
// groups right, 4&1==0 is 0 only when equality binds tighter than &, and
// 1<<2+1 is 8 only when addition binds tighter than the shift.

module test_expr_precedence_associativity;
  int a, b, c;

  initial begin
    $display("sub=%0d", 20 - 5 - 3);
    $display("mul=%0d add=%0d", 2 + 3 * 4, (2 + 3) * 4);
    $display("pow=%0d", 2 ** 3 ** 2);
    $display("cond=%0d", 1 ? 0 : 1 ? 2 : 3);
    $display("shift=%0d", 1 << 2 + 1);
    $display("rel=%0d", 1 < 2 == 1);
    $display("bitcmp=%0d", 4 & 1 == 0);
    $display("bitxor=%0d", 4'b1100 ^ 4'b1010 & 4'b0110);
    $display("logiccond=%0d", 1 || 0 ? 5 : 6);
    $display("unary=%0d unary2=%b", !0 + 1, ~2'b01 & 2'b11);
    $display("shiftadd=%0d", 8 >> 1 + 1);
    a = 3;
    b = a + 1;
    $display("assign=%0d,%0d", a, b);
    $display("rep=%b concat=%0d", {2{2'b10}}, {2'b10, 2'b01} == 4'b1001);
    c = 4;
    c += 2 * 3;
    $display("compound=%0d", c);
    $finish;
  end
endmodule
