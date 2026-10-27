/*
:name: test_ch16_sim_prop_inherited_eventually
:description: s_eventually[0:2] a under an outer clock counts its range in ticks of that clock, so a is required at the tick of the attempt, the next tick or the tick after it, and not within two time units (IEEE 1800-2023 Section 16.16.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.16.1 16.12.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ch16_sim_prop_inherited_eventually.expected
*/
// IEEE 1800-2023 §16.16.1: the set of semantic leading clocks of
// s_eventually q is {inherited}, so under the explicit clock c the range
// ticks are ticks of c. §16.12.13: s_eventually[0:2] a requires a at one of
// the ticks from the attempt tick through the second tick after it. The clock
// rises at 10, 30, 50, 70 and 90. go is sampled true at the tick at 10 only,
// so the first attempt covers the ticks 10, 30 and 50; a is false at 10 and
// 30 and true at 50, so the property passes at 50. If the range were counted
// in two time units the attempt would have failed at 12, long before 50.
// go is sampled true again at 90, and a is false at 90, 110 and 130, so the
// second attempt fails when the range is exhausted; the fail action prints
// no time, because the time at which a strong property reports the exhausted
// range is not fixed by the definition of the attempt interval.
// Neither simulator can run this test: Icarus Verilog 13.0 has no concurrent
// assertions and Verilator 5.052 reports "Unsupported: s_eventually[]". The
// expected output is the behavior §16.16.1 and §16.12.13 define.

`timescale 1ns/1ns

module test_ch16_sim_prop_inherited_eventually;
  logic clk = 0;
  logic go = 0;
  logic a = 0;

  always #10 clk = ~clk;

  a1: assert property (@(posedge clk) go |-> s_eventually[0:2] a)
    $display("pass at %0t", $time);
    else $display("fail");

  initial begin
    go = 1;
    #15 go = 0;
    #30 a = 1;
    #10 a = 0;
    #30 go = 1;
    #15 go = 0;
    #50;
    $display("done");
    $finish;
  end
endmodule
