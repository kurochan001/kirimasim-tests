/*
:name: test_clocking_multiple_blocks
:description: One signal sampled by two clocking blocks on the same clock with different skews, and a clockvar bound to a part-select (IEEE 1800-2023 Section 14.6)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.6 14.5 14.4 14.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_multiple_blocks.expected
*/
// IEEE 1800-2023 §14.6: a signal can appear in several clocking blocks, and
// blocks with the same clock share the same clocking event. Each block samples
// with its own input skew (14.4), so blocks with skews #3 and #1 can hold
// different values for the same edge. §14.5: a clockvar can stand for an
// expression such as a part-select of a signal. All blocks have updated their
// samples before a process waiting on one of them resumes (14.13).

`timescale 1ns/1ns

module test_clocking_multiple_blocks;
  logic clk = 0;
  logic [7:0] data = 0;

  always #5 clk = ~clk;   // posedges at 5, 15

  clocking early @(posedge clk);
    input #3 data;
    input #3 lo = data[3:0];
  endclocking

  clocking late @(posedge clk);
    input #1 data;
  endclocking

  initial begin
    #3 data = 8'h21;          // after early samples (2), before late samples (4)
    @(early);
    $display("%0d: early=%h late=%h early.lo=%h", $time, early.data, late.data, early.lo);
    #6 data = 8'h43;          // time 11, before both sample points of the next edge
    @(late);
    $display("%0d: early=%h late=%h early.lo=%h", $time, early.data, late.data, early.lo);
    $finish;
  end
endmodule
