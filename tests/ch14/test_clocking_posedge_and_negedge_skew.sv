/*
:name: test_clocking_posedge_and_negedge_skew
:description: Two clocking blocks on the same clock sample at their own edge and with their own skew, so they hold different values at the edges (IEEE 1800-2023 Sections 14.3, 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_posedge_and_negedge_skew.expected
*/
// IEEE 1800-2023 §14.3: each clocking block has its own clocking event, here
// the posedge and the negedge of one clock. §14.4: each block samples its
// input with its own skew, so the blocks see different values even though
// they read the same signal. §14.13: each block keeps its sampled value
// until its own next event. d changes at 2, 4, 7 and 9.5, so the posedge
// block with skew #2 samples at 3, 13 and 23 and the negedge block with
// skew #1 samples at 9 and 19.

`timescale 1ns/1ns

module test_clocking_posedge_and_negedge_skew;
  logic clk = 0;
  logic [3:0] d = 0;

  always #5 clk = ~clk;   // posedges at 5, 15; negedges at 10, 20

  clocking p @(posedge clk);
    input #2 d;
  endclocking

  clocking n @(negedge clk);
    input #1 d;
  endclocking

  initial begin
    #2 d = 1;
    #2 d = 2;
    #3 d = 3;
    #2.5 d = 4;
  end

  initial begin
    @(p);
    $display("%0d: p=%0d", $time, p.d);
    @(n);
    $display("%0d: n=%0d", $time, n.d);
    @(p);
    $display("%0d: p=%0d", $time, p.d);
    @(n);
    $display("%0d: n=%0d", $time, n.d);
    $finish;
  end
endmodule
