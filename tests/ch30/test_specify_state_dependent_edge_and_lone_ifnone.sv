/*
:name: test_specify_state_dependent_edge_and_lone_ifnone
:description: A state-dependent path can have a simple or an edge-sensitive path, ifnone takes a simple path that can stand for edge-sensitive conditional paths, and an ifnone path with no conditional path for the same source and destination acts as an unconditional path (IEEE 1800-2023 Sections 30.4.4, 30.4.4.3 and 30.4.4.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4 30.4.4.3 30.4.4.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_state_dependent_edge_and_lone_ifnone.expected
*/
// IEEE 1800-2023 §30.4.4: a state-dependent path is if (condition) with a
// simple path or with an edge-sensitive path, or ifnone with a simple path;
// its delay applies only while the condition is true. §30.4.4.3: with an
// edge-sensitive path it is an edge-sensitive state-dependent path.
// §30.4.4.4: ifnone gives the delay when the conditions of the other paths
// with the same source and destination are false; those paths may be
// edge-sensitive, and an ifnone path that has none is treated as an
// unconditional simple path.
//
// The cells and their paths:
//   sp: r = a;  if (s) (a => r) = 20;  if (!s) (a => r) = 50;
//   ep: q loads d at posedge clk;
//       if (en) (posedge clk => (q : d)) = 30;
//       if (!en) (posedge clk => (q : d)) = 70;
//   ln: n = a;  ifnone (a => n) = 40;   (no other path from a to n)
//   ie: q2 loads d at posedge clk;
//       if (en) (posedge clk => (q2 +: d)) = 60;  ifnone (clk => q2) = 20;
// s and en start at 1. a rises at 100: r at 120, n at 140. clk rises at 200
// with en 1: q at 230 and q2 at 260 (the ifnone path is not used while en is
// true, although its delay is smaller). s and en fall at 300, which changes
// no output. a falls at 400: n at 440 (the lone ifnone path does not depend
// on any state), r at 450. clk rises at 500 with en 0: q2 at 520 by the
// ifnone path, q at 570.
// Every change is at a multiple of 10. The outputs are sampled 5 after each
// multiple of 10 from 105 on, and a sample that differs from the one before
// prints the time of the change, 5 earlier, and the outputs. The 5.054
// release of Verilator ignores module path delays.

`timescale 1ns/1ns

module test_specify_state_dependent_edge_and_lone_ifnone_sp (input a, input s, output r);
  buf g (r, a);
  specify
    if (s) (a => r) = 20;
    if (!s) (a => r) = 50;
  endspecify
endmodule

module test_specify_state_dependent_edge_and_lone_ifnone_ep
  (input clk, input en, input d, output q);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf g (q, qi);
  specify
    if (en) (posedge clk => (q : d)) = 30;
    if (!en) (posedge clk => (q : d)) = 70;
  endspecify
endmodule

module test_specify_state_dependent_edge_and_lone_ifnone_ln (input a, output n);
  buf g (n, a);
  specify
    ifnone (a => n) = 40;
  endspecify
endmodule

module test_specify_state_dependent_edge_and_lone_ifnone_ie
  (input clk, input en, input d, output q2);
  reg qi = 0;
  always @(posedge clk) qi <= d;
  buf g (q2, qi);
  specify
    if (en) (posedge clk => (q2 +: d)) = 60;
    ifnone (clk => q2) = 20;
  endspecify
endmodule

module test_specify_state_dependent_edge_and_lone_ifnone;
  reg a = 0, s = 1, clk = 0, en = 1, d = 0;
  wire r, q, n, q2;
  logic [3:0] prev;

  test_specify_state_dependent_edge_and_lone_ifnone_sp usp (a, s, r);
  test_specify_state_dependent_edge_and_lone_ifnone_ep uep (clk, en, d, q);
  test_specify_state_dependent_edge_and_lone_ifnone_ln uln (a, n);
  test_specify_state_dependent_edge_and_lone_ifnone_ie uie (clk, en, d, q2);

  initial begin
    #100 a = 1;
    #90 d = 1;
    #10 clk = 1;        // 200
    #50 clk = 0;
    #50 s = 0;          // 300
    en = 0;
    #100 a = 0;         // 400
    #90 d = 0;
    #10 clk = 1;        // 500
  end

  initial begin
    #95 prev = {r, q, n, q2};
    repeat (55) begin
      #10 if ({r, q, n, q2} != prev)
        $display("%0d: r=%b q=%b n=%b q2=%b", $time - 5, r, q, n, q2);
      prev = {r, q, n, q2};
    end
    $finish;
  end
endmodule
