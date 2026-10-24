/*
:name: test_clocking_block_default_and_signal_skews
:description: a clocking block groups its clocking event with a default skew and per-signal skews, and its inputs, event and outputs follow them (IEEE 1800-2023 Section 14.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.2 14.3 14.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_block_default_and_signal_skews.expected
*/
// IEEE 1800-2023 §14.2: a clocking block, written between clocking and
// endclocking, groups a clocking event with the timing of the signals that are
// synchronous to it, so sampling, the clocking event and drives are relative
// to that event and the skews of the block. §14.3: a default clause gives the
// skew of each signal that does not give its own. §14.4: an input is sampled
// skew time units before the clock event, and an output is driven skew time
// units after it.
// cb, labeled at endclocking, has the default input skew 4 and output skew 3;
// v and y give their own skews, 2 and 6. clk first rises at 20. u is sampled
// at 16 and v at 18; each has one value at its sample time and others before
// and after it, so the other skew, or a sample at the clock event, prints
// another value. w is driven at 23 and y at 26, and each is printed just
// before and after that time.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns
module test_clocking_block_default_and_signal_skews;
  logic clk = 0;
  int u = 1, v = 10, w = 0, y = 0;

  always #20 clk = ~clk;

  clocking cb @(posedge clk);
    default input #4 output #3;
    input u;
    input #2 v;
    output w;
    output #6 y;
  endclocking : cb

  initial begin
    #15 u = 2;
    #2 u = 3;
    v = 11;
    #2 v = 12;
  end

  initial begin
    @(cb);
    $display("%0d cb: u=%0d v=%0d", $time, cb.u, cb.v);
    cb.w <= cb.u + 100;
    cb.y <= cb.v + 100;
  end

  initial begin
    #22 $display("22 w=%0d y=%0d", w, y);
    #2 $display("24 w=%0d y=%0d", w, y);
    #1 $display("25 w=%0d y=%0d", w, y);
    #2 $display("27 w=%0d y=%0d", w, y);
    $finish;
  end
endmodule
