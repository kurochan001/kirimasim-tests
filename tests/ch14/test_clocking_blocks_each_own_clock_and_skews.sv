/*
:name: test_clocking_blocks_each_own_clock_and_skews
:description: each of two clocking blocks samples, signals its event and drives relative to its own clock and skews (IEEE 1800-2023 Section 14.2)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.2 14.3 14.4 14.13 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_blocks_each_own_clock_and_skews.expected
*/
// IEEE 1800-2023 §14.2: a clocking block, written between clocking and
// endclocking, groups a clocking event with the timing of the signals that are
// synchronous to it, and a testbench may have several clocking blocks, each
// with its own clock and any number of signals. Input sampling, the clocking
// event and synchronous drives are then relative to the clock and the skews of
// that block: an input is sampled skew time units before the clock event
// (14.4), @(cb) resumes at the clock event (14.13), and an output takes the
// driven value skew time units after the clock event (14.16).
// cba has one input and one output with skew 2 on clk_a, which first rises at
// 10; cbb has two inputs and one output with skew 6 on clk_b, which first rises
// at 20. Each input has one value at its sample time and others before and
// after it, so a sample taken with the other block's skew or clock, or at the
// clock event, prints another value; each output is printed just before and
// just after its drive time, which the other block's skew would move across
// one of these prints.
// Icarus Verilog 13.0 does not support clocking blocks.

`timescale 1ns/1ns
module test_clocking_blocks_each_own_clock_and_skews;
  logic clk_a = 0, clk_b = 0;
  int da = 10, db = 20, dc = 30;
  int qa = 0, qb = 0;

  always #10 clk_a = ~clk_a;
  always #20 clk_b = ~clk_b;

  clocking cba @(posedge clk_a);
    input #2 da;
    output #2 qa;
  endclocking

  clocking cbb @(posedge clk_b);
    input #6 db, dc;
    output #6 qb;
  endclocking

  initial begin
    #7 da = 11;
    #2 da = 12;
    #4 db = 21;
    #2 dc = 31;
    #1 db = 22;
  end

  initial begin
    @(cba);
    $display("%0d cba: da=%0d", $time, cba.da);
    cba.qa <= cba.da + 1;
  end

  initial begin
    @(cbb);
    $display("%0d cbb: db=%0d dc=%0d", $time, cbb.db, cbb.dc);
    cbb.qb <= cbb.db + 1;
  end

  initial begin
    #11 $display("11 qa=%0d qb=%0d", qa, qb);
    #2 $display("13 qa=%0d qb=%0d", qa, qb);
    #12 $display("25 qa=%0d qb=%0d", qa, qb);
    #2 $display("27 qa=%0d qb=%0d", qa, qb);
    $finish;
  end
endmodule
