/*
:name: test_A_extra_throughout
:description: Throughout combines the expression en with the sequence a followed one tick later by b, and a clocking event prefixes the sequence expression, so the attempt succeeds when en holds at every tick of the match (IEEE 1800-2023 Sections 16.9.9 and 16.12, A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.9 16.12 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_A_extra_throughout.expected
*/
// IEEE 1800-2023 A.2.10, sequence_expr: expression_or_dist throughout
// sequence_expr combines the Boolean expression on the left with the sequence
// on the right, and clocking_event sequence_expr prefixes a sequence
// expression with a clocking event. The property p_chk writes both in one
// expression: at the tick of posedge clk, en must hold at every tick of the
// match of a ##1 b.
//
// a rises at 1 and b at 10, so a is sampled true at 5 and b at 15, and the
// match runs from 5 to 15. en is 1 throughout, so the attempt at 5 succeeds
// and no attempt fails. The count printed at 50 is 0.

`timescale 1ns/1ns
module test_A_extra_throughout;
  logic clk = 0, en = 1, a = 0, b = 0;
  int fails = 0;

  always #5 clk = ~clk;

  property p_chk;
    @(posedge clk) en throughout (a ##1 b);
  endproperty

  a_chk: assert property (p_chk) else fails++;

  initial begin
    #1 a = 1;
    #9 b = 1;
    #40 $display("fails=%0d", fails);
    $finish;
  end
endmodule
