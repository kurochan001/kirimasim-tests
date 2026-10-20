/*
:name: test_specify_edge_paths_by_edge
:description: Two edge-sensitive paths from the same clock to the same output, made unique by their edges, give the changes caused by each clock edge their own rise and fall delays (IEEE 1800-2023 Section 30.4.4.3)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.4.4.3 30.4.3 30.5.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specify_edge_paths_by_edge.expected
*/
// IEEE 1800-2023 §30.4.4.3, §30.4.3: edge-sensitive paths from the same source
// to the same destination may have different delays when their edges make
// them unique. Here the flip-flop loads d on both clock edges; a change that
// a rising edge causes takes (2, 3), one that a falling edge causes (6, 8),
// rise first (30.5.1). The rising edge at 10 makes q rise at 12, the falling
// edge at 20 makes it fall at 28, and so on; the edge at 40 does not change
// q. Changes before 10 are not printed.

`timescale 1ns/1ns

module dual_edge_ff (output q, input clk, input d);
  reg qi = 0;
  always @(posedge clk or negedge clk) qi <= d;
  buf (q, qi);
  specify
    (posedge clk => (q +: d)) = (2, 3);
    (negedge clk => (q +: d)) = (6, 8);
  endspecify
endmodule

module test_specify_edge_paths_by_edge;
  reg clk = 0, d = 0;
  wire q;

  dual_edge_ff u (q, clk, d);

  always @(q) if ($time >= 10) $display("%0d: q=%b", $time, q);

  initial begin
    #5 d = 1;
    #5 clk = 1;     // 10: loads 1, q rises at 12
    #5 d = 0;
    #5 clk = 0;     // 20: loads 0, q falls at 28
    #5 d = 1;
    #5 clk = 1;     // 30: loads 1, q rises at 32
    #10 clk = 0;    // 40: loads 1 again, no change
    #5 d = 0;
    #5 clk = 1;     // 50: loads 0, q falls at 53
    #5 d = 1;
    #5 clk = 0;     // 60: loads 1, q rises at 66
    #20 $finish;
  end
endmodule
