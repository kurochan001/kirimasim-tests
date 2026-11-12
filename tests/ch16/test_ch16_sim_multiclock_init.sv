/*
:name: test_ch16_sim_multiclock_init
:description: a local variable of a multiclocked property instance is initialized at the earliest tick of its semantic leading clock at or after the attempt start, not when the attempt starts (IEEE 1800-2023 Section 16.13.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.7 16.16.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_multiclock_init.expected
*/
// IEEE 1800-2023 §16.13.7: for a multiclock property instance with a single
// semantic leading clock, the local variable initialization assignment is
// performed at the earliest tick of that clock at or after the beginning of
// the evaluation attempt. sclk rises at 10, 30, 50 and so on, and c1 at 25
// and 75. go is sampled true at the sclk tick at 10 only. §16.13.2: from the
// end of the antecedent match at 10 a multiclocked |=> goes on to the nearest
// c1 tick that is strictly later, 25, and p is evaluated from there. p has
// one semantic leading clock, c1, so v = e is evaluated at the c1 tick at 25,
// where e has been 1 since 20. p then checks v == 1 at that tick and its pass
// action prints 25. A tool that evaluated the initializer when the antecedent
// matched would take e at 10, where e is 0, and the attempt would fail at 25.
// §20.11: by default the pass action also runs on a vacuous success, and go
// is sampled false at every later sclk tick, so the test calls
// $assertvacuousoff first and only the attempt of 10 prints.
// Corrected on 2026-11-12: the earlier version put the evaluation of p at 75,
// after an sclk tick at 30 that §16.13.2 does not use, and expected no output
// from the vacuous successes, which §20.11 gives by default.
// Neither simulator can run this test: Icarus Verilog 13.0 does not support
// these declarations and Verilator 5.052 stops with an internal fault on the
// multiclocked form. The expected output is the behavior §16.13.7 defines.

`timescale 1ns/1ns

module test_ch16_sim_multiclock_init;
  logic sclk = 0;
  logic c1 = 0;
  logic go = 0;
  logic e = 0;

  always #10 sclk = ~sclk;
  always #25 c1 = ~c1;

  property p;
    bit v = e;
    @(posedge c1) v == 1;
  endproperty

  a1: assert property (@(posedge sclk) go |=> p)
    $display("pass at %0t", $time);
    else $display("fail at %0t", $time);

  initial begin
    $assertvacuousoff;
    go = 1;
    #15 go = 0;
    #5 e = 1;
    #100;
    $display("done");
    $finish;
  end
endmodule
