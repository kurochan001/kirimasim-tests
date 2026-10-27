/*
:name: test_31_extra_setuphold_negative_limits
:description: A $setuphold with a negative setup limit and a positive hold limit whose sum is above the precision unit builds and runs, and its named delayed reference and delayed data are the delayed signals of the check (IEEE 1800-2023 Sections 31.3.3 and 31.9)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.3.3 31.9 31.9.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_31_extra_setuphold_negative_limits.expected
*/
// IEEE 1800-2023 31.3.3: $setuphold accepts negative limit values, and when
// either limit is negative the setup limit plus the hold limit shall exceed
// one simulation unit of precision (31.9). Here the limits are -3 ns and
// 8 ns with a precision of 1 ns, so -3 + 8 = 5 is above 1. The eighth and
// ninth arguments name dclk and dd as the delayed reference and delayed data
// of the check. Icarus Verilog 13.0 does not perform timing checks and says
// that the delayed reference and data signals become copies of the original
// signals, which is the behavior of 31.9.4 when timing checks are disabled.
// dclk therefore follows clk, dd follows d, and a flip-flop that samples dd
// at a rising edge of dclk stores the value d has at that edge. The test
// prints the signals before the first edge, after d has risen with clk still
// high, and after the second edge. A check that delayed dclk and dd by the
// magnitude of the negative limit would not show dclk and dd high at t=13.

`timescale 1ns/1ns

module tsn_cell(input wire clk, input wire d, output reg q = 0);
  wire dclk, dd;

  specify
    $setuphold(posedge clk, d, -3, 8, , , , dclk, dd);
  endspecify

  always @(posedge dclk) q <= dd;
endmodule

module test_31_extra_setuphold_negative_limits;
  reg clk = 0, d = 0;
  wire q;

  tsn_cell u(clk, d, q);

  task show;
    $display("t=%0d clk=%b dclk=%b d=%b dd=%b q=%b", $time, clk, u.dclk, d, u.dd, q);
  endtask

  initial begin
    #5 show;          // before any edge
    #5 clk = 1;       // 10: dclk follows clk
    #2 d = 1;         // 12: dd follows d
    #1 show;          // 13
    #2 clk = 0;       // 15
    #7 clk = 1;       // 22: dd is 1 at the edge
    #2 show;          // 24
    $finish;
  end
endmodule
