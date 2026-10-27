/*
:name: test_ch16_sim_prop_async_abort
:description: accept_on around a clock-free operand keeps the operand's inherited clock, so the attempt that starts at 5 is accepted at the clock tick at 15 where the abort condition is true, before the operand's b is false (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.12.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout_verilator: @test_ch16_sim_prop_async_abort.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of
// accept_on(b) q is the set of semantic leading clocks of q. The operand
// a ##1 b is clock-free, so its set is {inherited}; accept_on preserves that
// set, and the incoming clock c of go |-> ... remains the leading clock.
// go is sampled true only at the tick at 5, so one attempt starts there with
// a sampled true. b is sampled false at 15, which would fail the attempt, but
// g is sampled true at 15, so accept_on makes the attempt true at 15 and the
// cover statement runs there. The cover statement does not run for the later
// attempts whose antecedent go is false, because a vacuous success is not a
// match. §16.12.14 also makes accept_on an asynchronous
// abort evaluated at the granularity of the time step; Verilator 5.052
// evaluates the condition at the clock ticks only, which the notes record.
// Icarus Verilog 13.0 has no concurrent assertions, so it has no expected
// output of its own.

`timescale 1ns/1ns

module test_ch16_sim_prop_async_abort;
  logic clk = 0;
  logic go = 0;
  logic a = 0;
  logic b = 0;
  logic g = 0;

  always #5 clk = ~clk;

  c1: cover property (@(posedge clk) go |-> accept_on(g) (a ##1 b))
    $display("accepted at %0t", $time);

  initial begin
    go = 1;
    a = 1;
    #8 go = 0;
    #4 g = 1;
    #30;
    $display("done");
    $finish;
  end
endmodule
