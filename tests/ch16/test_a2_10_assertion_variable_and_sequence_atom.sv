/*
:name: test_a2_10_assertion_variable_and_sequence_atom
:description: A property body declares a variable that its match items set, and a parenthesized sequence with a match item carries the consecutive repetition [*2], so every completed attempt of the two properties passes (IEEE 1800-2023 Sections 16.9.2, 16.10 and 16.12, A.2.10)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2 16.10 16.12 A.2.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a2_10_assertion_variable_and_sequence_atom.expected
*/
// IEEE 1800-2023 A.2.10: a property body may hold assertion variable
// declarations, which are a variable data type and a list of variable
// declaration assignments. A sequence atom may be a parenthesized sequence
// expression with comma-separated match items and a sequence abbreviation,
// which is a consecutive repetition.
//
// a is 1 from time 1 to 40 and b is 1 from 20 to 50, so the clock ticks at 5,
// 15, 25, 35, 45 and 55. p_var declares k, sets it to 1 in the first match
// item and adds 1 in the second, and then checks that it is 2; the attempts at
// 15 and 25 have both their matches, so they pass, and the others have no
// match. p_atom declares m, sets it to 2 on each of two consecutive ticks of
// (a) and checks it in the consequent. Both assertions pass at each tick, so
// the printed counts are 12 passes and no failure; a tool that did not carry
// out the match items would fail the attempts that reach the consequent.

`timescale 1ns/1ns
module test_a2_10_assertion_variable_and_sequence_atom;
  bit clk = 0;
  always #5 clk = ~clk;

  logic a = 0, b = 0;
  int passes = 0;
  int fails = 0;

  property p_var;
    int k;
    (a, k = 1) ##1 (b, k = k + 1) |-> (k == 2);
  endproperty

  property p_atom;
    int m;
    (a, m = 2)[*2] |-> (m == 2);
  endproperty

  ap_var: assert property (@(posedge clk) p_var)
    passes++; else fails++;
  ap_atom: assert property (@(posedge clk) p_atom)
    passes++; else fails++;

  initial begin
    #1 a = 1;
    #19 b = 1;
    #20 a = 0;
    #10 b = 0;
    #10 $display("passes %0d fails %0d", passes, fails);
    $finish;
  end
endmodule
