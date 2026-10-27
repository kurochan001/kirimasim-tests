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
// the evaluation attempt. sclk rises at 10, 30 and 50 and c1 at 25 and 75.
// go is sampled true at the sclk tick at 10, and go |=> p makes the attempt
// of p begin at the next sclk tick, 30, which is not a c1 tick. p has one
// semantic leading clock, c1, so v = e is evaluated at the c1 tick at 75,
// where e has been 1 since 40. p then checks v == 1 at that tick and its pass
// action prints 75. A tool that evaluated the initializer when the attempt
// began would take e at 30, where e is 0, and the attempt would fail at 75.
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
    go = 1;
    #15 go = 0;
    #25 e = 1;
    #100;
    $display("done");
    $finish;
  end
endmodule
