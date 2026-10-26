/*
:name: test_zero_repetition_no_sample
:description: Zero consecutive repetition takes no sample at any clock tick, so a[*0] matches only the empty trace and a ##1 b needs b one tick later, whether a[*0] is the consequent of an overlapping implication or the antecedent of a nonoverlapping one (IEEE 1800-2023 Section 16.12.22)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.22
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_zero_repetition_no_sample.expected
*/
// IEEE 1800-2023 §16.12.22: a zero consecutive repetition takes no sample at
// any clock tick and can match only on an empty trace. a is 0 at every tick.
// The clock has a positive edge at 10 and at 20. At 10 start is 1, so the
// consequent a[*0] ##1 b of p_zero starts: it consumes no tick at 10 and needs
// b at 20. The antecedent of p_ant is a[*0]; it matches empty at 10, so |=> 
// needs b one tick later, at 20. b is 1 when the clock rises at 20, so both
// attempts pass. If a[*0] sampled a at 10, both would fail because a is 0.
// The second attempts, which start at 20, need b at 30 and are still pending
// when the counters are printed at 25.

`timescale 1ns/1ns

module test_zero_repetition_no_sample;
  logic clk = 0;
  logic start = 0;
  logic a = 0;
  logic b = 0;
  int pass_zero = 0, fail_zero = 0;
  int pass_ant = 0, fail_ant = 0;

  p_zero: assert property (@(posedge clk) start |-> (a[*0] ##1 b))
    pass_zero++; else fail_zero++;
  p_ant: assert property (@(posedge clk) (a[*0]) |=> b)
    pass_ant++; else fail_ant++;

  initial begin
    #5 start = 1;          // 5: start is 1 at the edge at 10
    #5 clk = 1;            // 10: both attempts start
    #5 clk = 0;            // 15
    #4 b = 1;              // 19: b is 1 at the edge at 20
    #1 clk = 1;            // 20: both attempts complete
    #5 $display("zero: pass=%0d fail=%0d; antecedent: pass=%0d fail=%0d",
                pass_zero, fail_zero, pass_ant, fail_ant);
    $finish;
  end
endmodule
