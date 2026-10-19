/*
:name: test_clocking_input_output_skew
:description: Clocking block inputs are sampled their skew before the clock event, or in the Observed region with #0, and outputs are driven their skew after it (IEEE 1800-2023 Section 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.4 14.13 14.16 14.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_input_output_skew.expected
*/
// IEEE 1800-2023 §14.4, §14.13: a clocking block input with skew #2 holds the
// value its signal had 2 time units before the clocking event; with an explicit
// #0 it is sampled at the event itself, in the Observed region. §14.16: an
// output with skew #3 changes its signal 3 time units after the event at which
// it was driven. §14.5: a clockvar can be given another name with = and an
// expression.

`timescale 1ns/1ns

module test_clocking_input_output_skew;
  logic clk = 0;
  logic [3:0] d = 0;
  logic [3:0] q = 0;

  always #5 clk = ~clk;   // posedges at 5, 15, 25

  clocking ck @(posedge clk);
    input #2 d;
    input #0 dz = d;
    output #3 q;
  endclocking

  initial begin
    #4 d = 1;
    @(ck);
    $display("%0d: ck.d=%0d ck.dz=%0d", $time, ck.d, ck.dz);
    d = 2;
    ck.q <= 4'd9;
    #2 $display("%0d: q=%0d", $time, q);
    #2 $display("%0d: q=%0d", $time, q);
    @(ck);
    $display("%0d: ck.d=%0d ck.dz=%0d", $time, ck.d, ck.dz);
    $finish;
  end
endmodule
