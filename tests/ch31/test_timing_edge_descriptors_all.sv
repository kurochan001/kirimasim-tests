/*
:name: test_timing_edge_descriptors_all
:description: Each edge descriptor of an edge-control specifier selects exactly its transition among 0, 1 and x, a transition to or from z counts as the same transition with x, x and z can be written in capitals, a list can hold up to six descriptors, and posedge and negedge are the lists edge[01, 0x, x1] and edge[10, x0, 1x] (IEEE 1800-2023 Section 31.5)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.5 31.3.2 31.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_edge_descriptors_all.expected
*/
// IEEE 1800-2023 §31.5: edge[...] holds one to six of the descriptors 01, 0x,
// 10, 1x, x0 and x1, each naming one transition; x and z can be written as x,
// X, z or Z, and transitions involving z are treated like those involving x.
// posedge is edge[01, 0x, x1] and negedge is edge[10, x0, 1x]. §31.3.2: a
// $hold whose reference event is the edge-controlled clk reports a d change
// less than 2 after a matching clk transition. §31.6: each violation toggles
// the notifier.
//
// clk makes ten transitions, 10 apart: 0->1 at 10, 1->x at 20, x->0 at 30,
// 0->x at 40, x->1 at 50, 1->0 at 60, 0->z at 70, z->1 at 80, 1->z at 90 and
// z->0 at 100. d changes 1 after each of them, so every check reports at
// T + 1 exactly for the transitions at T that its reference event matches:
//   edge[01] 11; edge[10] 61; edge[0x] 41 and 71 (0->z); edge[x0] 31 and 101
//   (z->0); edge[1x] 21 and 91 (1->z); edge[x1] 51 and 81 (z->1);
//   edge[0X, Z1] 41, 51, 71 and 81; the list of all six, every transition;
//   posedge and edge[01, 0x, x1] 11, 41, 51, 71 and 81; negedge and
//   edge[10, x0, 1x] 21, 31, 61, 91 and 101.
// The times at which each notifier changes are printed at the end.
//
// Icarus Verilog 13.0 skips timing checks, so the notifiers never change.

`timescale 1ns/1ns

module ted_checks (input clk, d);
  reg n01 = 0, n10 = 0, n0x = 0, nx0 = 0, n1x = 0, nx1 = 0, nup = 0, nall = 0;
  reg npos = 0, nposl = 0, nneg = 0, nnegl = 0;
  specify
    $hold(edge[01] clk, d, 2, n01);
    $hold(edge[10] clk, d, 2, n10);
    $hold(edge[0x] clk, d, 2, n0x);
    $hold(edge[x0] clk, d, 2, nx0);
    $hold(edge[1x] clk, d, 2, n1x);
    $hold(edge[x1] clk, d, 2, nx1);
    $hold(edge[0X, Z1] clk, d, 2, nup);
    $hold(edge[01, 10, 0x, x0, 1x, x1] clk, d, 2, nall);
    $hold(posedge clk, d, 2, npos);
    $hold(edge[01, 0x, x1] clk, d, 2, nposl);
    $hold(negedge clk, d, 2, nneg);
    $hold(edge[10, x0, 1x] clk, d, 2, nnegl);
  endspecify
endmodule

module test_timing_edge_descriptors_all;
  reg clk = 0, d = 0;
  logic seq[10] = '{1'b1, 1'bx, 1'b0, 1'bx, 1'b1, 1'b0, 1'bz, 1'b1, 1'bz, 1'b0};
  string l01 = "", l10 = "", l0x = "", lx0 = "", l1x = "", lx1 = "", lup = "", lall = "";
  string lpos = "", lposl = "", lneg = "", lnegl = "";

  ted_checks u (clk, d);

  always @(u.n01) l01 = {l01, $sformatf(" %0d", $time)};
  always @(u.n10) l10 = {l10, $sformatf(" %0d", $time)};
  always @(u.n0x) l0x = {l0x, $sformatf(" %0d", $time)};
  always @(u.nx0) lx0 = {lx0, $sformatf(" %0d", $time)};
  always @(u.n1x) l1x = {l1x, $sformatf(" %0d", $time)};
  always @(u.nx1) lx1 = {lx1, $sformatf(" %0d", $time)};
  always @(u.nup) lup = {lup, $sformatf(" %0d", $time)};
  always @(u.nall) lall = {lall, $sformatf(" %0d", $time)};
  always @(u.npos) lpos = {lpos, $sformatf(" %0d", $time)};
  always @(u.nposl) lposl = {lposl, $sformatf(" %0d", $time)};
  always @(u.nneg) lneg = {lneg, $sformatf(" %0d", $time)};
  always @(u.nnegl) lnegl = {lnegl, $sformatf(" %0d", $time)};

  initial begin
    foreach (seq[i]) begin
      #(10 * (i + 1) - $time) clk = seq[i];   // 10, 20, ..., 100
      #1 d = ~d;                             // 1 after each clk transition
    end
    #10 $display("edge[01]:%s", l01);
    $display("edge[10]:%s", l10);
    $display("edge[0x]:%s", l0x);
    $display("edge[x0]:%s", lx0);
    $display("edge[1x]:%s", l1x);
    $display("edge[x1]:%s", lx1);
    $display("edge[0X, Z1]:%s", lup);
    $display("edge[01, 10, 0x, x0, 1x, x1]:%s", lall);
    $display("posedge:%s", lpos);
    $display("edge[01, 0x, x1]:%s", lposl);
    $display("negedge:%s", lneg);
    $display("edge[10, x0, 1x]:%s", lnegl);
  end
endmodule
