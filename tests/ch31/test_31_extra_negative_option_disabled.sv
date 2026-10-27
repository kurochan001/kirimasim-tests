/*
:name: test_31_extra_negative_option_disabled
:description: With negative limits and without the negative timing check option, the explicitly declared delayed reference and data signals are copies of the original signals and change in the same time step, not after a delay (IEEE 1800-2023 Section 31.9.4)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.9.4 31.9.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_31_extra_negative_option_disabled.expected
*/
// IEEE 1800-2023 31.9.4: negative timing handling shall be enabled with an
// invocation option. Without that option, or when an option turns off all
// timing checks, the delayed reference and data signals of $setuphold and
// $recrem become copies of the original reference and data signals. Icarus
// Verilog 13.0 performs no timing checks and reports that the delayed
// reference and data signals become copies of the original signals. The cell
// below has a -3 ns setup limit, so with the option the check would create a
// delayed clock, but the test runs without it. At the time step of the rising
// clk edge dclk is therefore already 1, and at the time step in which d rises
// dd is already 1; a delayed copy would still hold the old value in that same
// time step. The flip-flop samples the copy dd at the copy dclk.

`timescale 1ns/1ns

module tno_cell(input wire clk, input wire d, output reg q = 0);
  wire dclk, dd;

  specify
    $setuphold(posedge clk, d, -3, 8, , , , dclk, dd);
  endspecify

  always @(posedge dclk) q <= dd;
endmodule

module test_31_extra_negative_option_disabled;
  reg clk = 0, d = 0;
  wire q;

  tno_cell u(clk, d, q);

  initial begin
    #10 clk = 1;
    #0 $display("t=%0d clk=%b dclk=%b", $time, clk, u.dclk);
    #2 d = 1;
    #0 $display("t=%0d d=%b dd=%b", $time, d, u.dd);
    #3 clk = 0;
    #5 clk = 1;
    #2 $display("t=%0d q=%b", $time, q);
    $finish;
  end
endmodule
