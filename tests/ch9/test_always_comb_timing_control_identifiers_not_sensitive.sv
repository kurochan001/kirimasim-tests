/*
:name: test_always_comb_timing_control_identifiers_not_sensitive
:description: identifiers that appear in an always_comb only in the intra-assignment delay, event, iff and repeat controls of nonblocking assignments do not wake the procedure, while the right-hand sides do (IEEE 1800-2023 Section 9.2.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_timing_control_identifiers_not_sensitive.expected
*/
// IEEE 1800-2023 §9.2.2.2.1: the implicit sensitivity list of an always_comb
// leaves out identifiers that appear only in timing control expressions.
// An always_comb cannot contain a control that blocks (§9.2.2.2.2), so wait
// statements cannot appear in it, but a nonblocking assignment can carry an
// intra-assignment delay or event control, as in the always_comb example of
// §9.2.2.2. Here dly appears only in a delay, clk and gate only in event
// expressions (gate after iff) and cnt only in the count of a repeat event
// control; a, b and c are the right-hand sides. runs is read and written by
// the block, so it is not in the list either, and it counts the executions.
//
// The block runs once at time 0. Then dly, cnt and gate change, clk rises and
// falls, and the pending assignments complete: y at time 2 (dly was 2), z at
// the rising edge, w at the falling edge (cnt was 1). None of these changes
// runs the block again, so runs stays 1; a tool that put dly, cnt, gate or
// clk in the list would print a larger count after that change. A change of
// a then runs the block, and runs becomes 2.
//
// Icarus Verilog 13.0 does not accept iff in an event expression (a syntax
// error), and without it rejects a nonblocking assignment with an event
// control in an always_comb, a construct the standard allows; with only the
// delay control left, it keeps dly out of the list as expected. The 5.054
// release of Verilator does not support the repeat event control, and
// without it stops with an internal error on the event control in the
// always_comb. The expected output follows the standard.

`timescale 1ns/1ns

module test_always_comb_timing_control_identifiers_not_sensitive;
  logic clk = 0, gate = 1;
  int dly = 2, cnt = 1;
  int a = 1, b = 10, c = 100;
  int y, z, w;
  int runs;

  always_comb begin
    runs++;
    y <= #(dly) a;
    z <= @(posedge clk iff gate) b;
    w <= repeat (cnt) @(negedge clk) c;
  end

  initial begin
    #1 $display("t=1 runs=%0d y=%0d z=%0d w=%0d", runs, y, z, w);
    dly = 7;
    #2 $display("t=3 runs=%0d y=%0d (dly changed)", runs, y);
    cnt = 4;
    #1 $display("t=4 runs=%0d (cnt changed)", runs);
    gate = 0;
    #1 $display("t=5 runs=%0d (gate changed)", runs);
    gate = 1;
    #1 $display("t=6 runs=%0d (gate changed back)", runs);
    clk = 1;
    #1 $display("t=7 runs=%0d z=%0d (clk rose)", runs, z);
    clk = 0;
    #1 $display("t=8 runs=%0d w=%0d (clk fell)", runs, w);
    a = 2;
    #1 $display("t=9 runs=%0d (a changed)", runs);
    $finish;
  end
endmodule
