/*
:name: test_ch16_sim_prop_async_abort
:description: accept_on around a clock-free operand keeps the operand's inherited clock, so the attempt that starts at 5 is accepted at the clock tick at 15 where the abort condition is true, before the operand's b is false; the negation of the abort property fails there (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.12.14 16.12.3 16.14.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_prop_async_abort.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of
// accept_on(b) q is the set of semantic leading clocks of q. The operand
// a ##1 b is clock-free, so its set is {inherited}; accept_on preserves that
// set, and the incoming clock c of go |-> ... remains the leading clock.
// go is sampled true only at the tick at 5, so one attempt starts there with
// a sampled true. b is sampled false at 15, which would make a ##1 b false,
// but g is sampled true at 15, and §16.12.14 lets the abort condition win in
// the time step where the operand ends, so the abort property is true at 15.
// §16.12.14 also makes accept_on an asynchronous abort evaluated at the
// granularity of the time step with sampled values: g changes to 1 at 12,
// where its sampled value is still 0, so the abort happens at the tick at 15.
// A tool that evaluates the condition at the clock ticks only, as Verilator
// 5.052 does, gives the same time here.
// §16.14.8 makes an evaluation that the abort condition ends vacuous, and the
// standard can be read both ways on whether a pass statement runs for a
// vacuous success (§16.14.3 and §16.14.8 against §20.11). The test therefore
// does not look at a pass statement: it asserts the negation of the abort
// property (§16.12.3), which fails at 15 for the attempt from 5, and prints
// from the fail action. The later attempts, whose antecedent go is false,
// succeed vacuously and run no fail action.
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

  a1: assert property (@(posedge clk) go |-> not (accept_on(g) (a ##1 b)))
    else $display("accepted at %0t", $time);

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
