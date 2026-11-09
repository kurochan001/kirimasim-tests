/*
:name: test_clocking_drive_rhs_now_update_after_cycles_and_skew
:description: a synchronous drive with a cycle delay does not block and evaluates its right-hand side at once, and its signal changes after that many cycles of the clocking block plus the output skew, as the signal of a drive that matures at the current event changes after the skew (IEEE 1800-2023 Section 14.16)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.16 14.4 14.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_drive_rhs_now_update_after_cycles_and_skew.expected
*/
// IEEE 1800-2023 §14.16: a cycle delay on the right-hand side of a
// synchronous drive does not make the statement block, and the right-hand
// side is evaluated at once even with a cycle delay; the signal is updated
// after that many cycles of the clocking block of the clockvar, plus its
// output skew. Whether a drive matures at the current clocking event or at a
// later one, the signal changes the output skew after that event. §14.4: an
// output skew of #2 drives the signal two time units after the event.
//
// The posedges are at 5, 15, 25, 35. At the event at 5 the process drives
// cb.w <= r, which matures at that event, and cb.v <= ##2 r, which matures at
// the event at 25; r is 1 when both drives execute and is set to 9 right
// after them, in the same time step. w changes to 1 at 7, and v changes to 1
// at 27; v is still 0 at 18, after one cycle and the skew, and at 26.
// A simulator that blocks on the cycle delay prints the first line at 25, one
// that evaluates the right-hand side when the drive matures prints v=9, and
// one that leaves out the skew changes w at 5 or v at 25.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns

module test_clocking_drive_rhs_now_update_after_cycles_and_skew;
  logic clk = 0;
  int r = 1;
  int v = 0, w = 0;

  always #5 clk = ~clk;

  default clocking cb @(posedge clk);
    output #2 v, w;
  endclocking

  initial begin
    @(cb);
    cb.w <= r;
    cb.v <= ##2 r;
    r = 9;
    $display("t=%0t after the drives: r=%0d", $time, r);
    #1 $display("t=%0t v=%0d w=%0d", $time, v, w);
    #2 $display("t=%0t v=%0d w=%0d", $time, v, w);
    #10 $display("t=%0t v=%0d w=%0d", $time, v, w);
    #8 $display("t=%0t v=%0d w=%0d", $time, v, w);
    #2 $display("t=%0t v=%0d w=%0d", $time, v, w);
    $finish;
  end
endmodule
