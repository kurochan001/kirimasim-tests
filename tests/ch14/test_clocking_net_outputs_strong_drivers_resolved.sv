/*
:name: test_clocking_net_outputs_strong_drivers_resolved
:description: A clocking output whose signal is a net adds a (strong1, strong0) driver that starts as z, and the persistent drivers of several clocking blocks are resolved with the other drivers of the net by its net type (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.16.2 21.2.1.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_clocking_net_outputs_strong_drivers_resolved.expected
*/
// IEEE 1800-2023 §14.16: for each clocking block output whose signal is a
// net, a driver with (strong1, strong0) strength is created on the net. It
// is updated like a continuous assignment from a hidden variable that the
// drives set, and it starts as 'z, so it has no effect until the first
// drive. §14.16.2: each clocking block output to a net has its own such
// driver, and all of them and the other drivers of the net are resolved
// according to the net type.
//
// tn is a tri net with a (weak0, weak1) driver of 0. wn is a wand and wo a
// wor net, each with a continuous assignment (1 and 0) and driven by the
// clocking blocks c1 and c2. Before any drive, tn is weak 0 (shown by %v as
// We0) and wn and wo have the values of their continuous assignments. The
// drives at the events at 5, 15 and 25 are:
//   at 5:  c1: tn 1, wn 0, wo 1   c2: wn 1, wo 0
//   at 15: c1: tn 0               c2: wn 1, wo 0
//   at 25: c1: wn 1, wo 0
// tn becomes strong 1 (St1), then strong 0 (St0); right after the drives
// at 5 the process does flag <= 1, and the always procedure woken by that
// NBA update still reads tn as 0, since the hidden variable behind the
// driver changes only in the Re-NBA region. At 5, wn is 0 & 1 & 1 = 0
// and wo is 1 | 0 | 0 = 1. At 15, c1 does not drive wn or wo, and its
// drivers keep 0 and 1, so wn stays 0 and wo stays 1. At 25 wn is
// 1 & 1 & 1 = 1 and wo is 0 | 0 | 0 = 0.
//
// Simulator notes: Icarus Verilog 13.0 does not support clocking blocks.
// In a run with Verilator 5.052, which has no drive strengths, tn is St0 at
// time 1, and it warns that it treats the clocking outputs to these nets as
// variables written by several drivers.

`timescale 1ns/1ns

module test_clocking_net_outputs_strong_drivers_resolved;
  logic clk = 0;
  tri tn;
  wand wn;
  wor wo;
  bit flag = 0;
  logic seen_tn;

  assign (weak0, weak1) tn = 1'b0;
  assign wn = 1'b1;
  assign wo = 1'b0;

  always #5 clk = ~clk;

  always @(flag) seen_tn = tn;

  clocking c1 @(posedge clk);
    output tn, wn, wo;
  endclocking

  clocking c2 @(posedge clk);
    output wn, wo;
  endclocking

  initial begin
    #1 $display("t=%0t tn=%v wn=%b wo=%b", $time, tn, wn, wo);
    @(c1);
    c1.tn <= 1'b1;
    c1.wn <= 1'b0;
    c1.wo <= 1'b1;
    c2.wn <= 1'b1;
    c2.wo <= 1'b0;
    flag <= 1'b1;
    #1 $display("t=%0t tn=%v wn=%b wo=%b", $time, tn, wn, wo);
    $display("t=%0t tn read after the NBA at 5: %b", $time, seen_tn);
    @(c1);
    c1.tn <= 1'b0;
    c2.wn <= 1'b1;
    c2.wo <= 1'b0;
    #1 $display("t=%0t tn=%v wn=%b wo=%b", $time, tn, wn, wo);
    @(c1);
    c1.wn <= 1'b1;
    c1.wo <= 1'b0;
    #1 $display("t=%0t tn=%v wn=%b wo=%b", $time, tn, wn, wo);
    $finish;
  end
endmodule
